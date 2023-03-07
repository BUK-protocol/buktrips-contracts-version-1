// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ISupplierContract.sol";
import "./IBukSupplierDeployer.sol";
import "./IBukSupplierUtilityDeployer.sol";
import "./ITreasury.sol";
import "./ISupplierContractUtility.sol";

/**
* @title BUK Protocol Factory Contract
* @author BUK Technology Inc
* @dev Genesis contract for managing all operations of the BUK protocol including ERC1155 token management for room-night NFTs and underlying sub-contracts such as Supplier, Hotel, Treasury, and Marketplace.
*/
contract BukTrips is AccessControl, ReentrancyGuard {

    /**
    * @dev Enum for booking statuses.
    * @var BookingStatus.nil         Booking has not yet been initiated.
    * @var BookingStatus.booked      Booking has been initiated but not yet confirmed.
    * @var BookingStatus.confirmed   Booking has been confirmed.
    * @var BookingStatus.cancelled   Booking has been cancelled.
    * @var BookingStatus.expired     Booking has expired.
    */
    enum BookingStatus {nil, booked, confirmed, cancelled, expired}

    /**
    * @dev Addresses for the Buk wallet, currency, treasury, supplier deployer, and utility deployer.
    * @dev address buk_wallet        Address of the Buk wallet.
    * @dev address currency          Address of the currency.
    * @dev address treasury          Address of the treasury.
    * @dev address supplier_deployer Address of the supplier deployer.
    * @dev address utility_deployer  Address of the utility deployer.
    */
    address internal buk_wallet;
    address internal currency;
    address internal treasury;
    address public supplier_deployer;
    address public utility_deployer;
    /**
    * @dev Commission charged on bookings.
    */
    uint8 internal commission = 5;

    /**
    * @dev Counters.Counter supplierIds   Counter for supplier IDs.
    * @dev Counters.Counter bookingIds    Counter for booking IDs.
    */
    uint256 internal _supplierIds;
    uint256 internal _bookingIds;

    /**
    * @dev Struct for booking details.
    * @var uint256 id                Booking ID.
    * @var BookingStatus status      Booking status.
    * @var uint256 tokenID           Token ID.
    * @var address owner             Address of the booking owner.
    * @var uint256 supplierId        Supplier ID.
    * @var uint256 checkin          Check-in date.
    * @var uint256 checkout          Check-out date.
    * @var uint256 total             Total price.
    * @var uint256 baseRate          Base rate.
    */
    struct Booking {
        uint256 id;
        BookingStatus status;
        uint256 tokenID;
        address owner;
        uint256 supplierId;
        uint256 checkin;
        uint256 checkout;
        uint256 total;
        uint256 baseRate;
    }
    /**
    * @dev Struct for supplier details.
    * @var uint256 id                Supplier ID.
    * @var bool status               Supplier status.
    * @var address supplier_contract Address of the supplier contract.
    * @var address supplier_owner    Address of the supplier owner.
    * @var address utility_contract  Address of the utility contract.
    */
    struct SupplierDetails {
        uint256 id;
        bool status;
        address supplier_contract;
        address supplier_owner;
        address utility_contract;
    }

    /**
    * @dev Constant for the role of admin
    */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    /**
    * @dev mapping(uint256 => Booking) BookingDetails   Mapping of booking IDs to booking details.
    */
    mapping(uint256 => Booking) public BookingDetails; //bookingID -> Booking Details
    /**
    * @dev mapping(uint256 => mapping(uint256 => uint256)) TimeLocks   Mapping of booking IDs to time locks.
    */
    mapping(uint256 => mapping(uint256 => uint256)) public TimeLocks; //bookingID -> Booking Details
    /**
    * @dev mapping(uint256 => SupplierDetails) Suppliers   Mapping of supplier IDs to supplier details.
    */
    mapping(uint256 => SupplierDetails) public Suppliers; //supplierID -> Contract Address

    /**
    * @dev Emitted when the deployers are set.
    */
    event SetDeployers(address indexed supplier_deployer, address indexed utility_deployer);
    /**
    * @dev Emitted when the commission is set.
    */
    event SetCommission(uint256 indexed commission);
    /**
    * @dev Emitted when nft status is toggled.
    */
    event ToggleNFT(uint256 indexed supplier_id, uint256 indexed nft_id);
    /**
    * @dev Emitted when the supplier details are updated.
    */
    event UpdateSupplierDetails(uint256 indexed id, string indexed name);
    /**
    * @dev Emitted when the supplier is registered.
    */
    event RegisterSupplier(uint256 indexed id, address indexed supplier_contract, address indexed utility_contract);
    /**
    * @dev Emitted when time lock is set for an NFT.
    */
    event SetTimeLock(uint256 indexed supplier_id, uint256 indexed nft_id, uint256 indexed time);
    /**
    * @dev Emitted when treasury is updated.
    */
    event SetTreasury(address indexed treasury_contract);
    /**
    * @dev Emitted when single room is booked.
    */
    event BookRoom(uint256 indexed booking);
    /**
    * @dev Emitted when multiple rooms are booked together.
    */
    event BookRooms(uint256[] indexed bookings, uint256 indexed total, uint256 indexed commission);
    /**
    * @dev Emitted when booking refund is done.
    */
    event BookingRefund(uint256 indexed total, address indexed owner);
    /**
    * @dev Emitted when room bookings are confirmed.
    */
    event ConfirmRooms(uint256[] indexed bookings, bool indexed status);
    /**
    * @dev Emitted when room bookings are checked out.
    */
    event CheckoutRooms(uint256[] indexed bookings, bool indexed status);
    /**
    * @dev Emitted when room bookings are cancelled.
    */
    event CancelRoom(uint256 indexed booking, bool indexed status);

    /**
    * @dev Modifier to check the access to toggle NFTs.
    */
    modifier checkAccess(uint256 _booking_id) {
        require(((hasRole(ADMIN_ROLE, _msgSender())) || (_msgSender()==BookingDetails[_booking_id].owner)), "Caller does not have access");
        _;
    }

    /**
    * @dev Constructor to initialize the contract
    * @param _treasury Address of the treasury.
    * @param _currency Address of the currency.
    * @param _buk_wallet Address of the Buk wallet.
    */
    constructor (address _treasury, address _currency, address _buk_wallet) {
        currency = _currency;
        treasury = _treasury;
        buk_wallet = _buk_wallet;
        _grantRole(ADMIN_ROLE, _msgSender());
    }

    /**
    * @dev Function to set the deployer contracts.
    * @param _supplier_deployer Address of the supplier deployer contract.
    * @param _utility_deployer Address of the utility deployer contract.
    * @notice Only admin can call this function.
    */
    function setDeployers(address _supplier_deployer, address _utility_deployer) external onlyRole(ADMIN_ROLE) {
        supplier_deployer = _supplier_deployer;
        utility_deployer = _utility_deployer;
        emit SetDeployers(_supplier_deployer, _utility_deployer);
    }

    /**
    * @dev Function to update the treasury address.
    * @param _treasury Address of the treasury.
    */
    function setTreasury(address _treasury) external onlyRole(ADMIN_ROLE) {
        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    /**
    * @dev Function to update the supplier details.
    * @param _supplierId ID of the supplier.
    * @param _name New name of the supplier.
    */
    function updateSupplierDetails(uint256 _supplierId, string memory _name) external onlyRole(ADMIN_ROLE) {
        ISupplierContract(Suppliers[_supplierId].supplier_contract).updateSupplierDetails(_name);
        emit UpdateSupplierDetails(_supplierId,_name);
    }

    /**
    * @dev Function to set the Buk commission percentage.
    * @param _commission Commission percentage.
    */
    function setCommission(uint8 _commission) external onlyRole(ADMIN_ROLE) {
        commission = _commission;
        emit SetCommission(_commission);
    }
    
    /**
    * @dev Function to set the time lock for NFT Transfer.
    * @param _supplierId ID of the supplier.
    * @param _nft_id ID of the NFT.
    * @param _time_lock Time lock in hours.
    */
    function setTransferLock(uint256 _supplierId, uint256 _nft_id, uint256 _time_lock) external onlyRole(ADMIN_ROLE) {
        TimeLocks[_supplierId][_nft_id] = 3600 * _time_lock;
        emit SetTimeLock(_supplierId, _nft_id, _time_lock);
    }

    /** 
    * @dev Function to toggle the NFT status.
    * @param _id ID of the NFT.
    * @param status Status of the NFT.
    * @notice Only admin or the owner of the NFT can call this function.
    */
    function toggleNFTStatus(uint _id, bool status) external nonReentrant() checkAccess(_id) {
        require((BookingDetails[_id].tokenID > 0), "NFT does not exist");
        uint256 threshold = BookingDetails[_id].checkin - TimeLocks[BookingDetails[_id].supplierId][_id];
        require((block.timestamp < threshold), "NFT toggle not possible now");
        ISupplierContract(Suppliers[BookingDetails[_id].supplierId].supplier_contract).toggleNFTStatus(_id, status);
        emit ToggleNFT(BookingDetails[_id].supplierId, _id);
    }

    /**
    * @dev Function to register a supplier.
    * @param _name Name of the supplier.
    * @param _supplier_owner Address of the supplier owner.
    * @param _contract_uri URI of the supplier contract.
    * @notice Only admin can call this function.
    */
    function registerSupplier(string memory _contract_name, string memory _name, address _supplier_owner, string memory _contract_uri) external onlyRole(ADMIN_ROLE) {
        ++_supplierIds;
        address utility_contract_addr = IBukSupplierUtilityDeployer(utility_deployer).deploySupplierUtility(_contract_name,_supplierIds,_name, _contract_uri);
        address supplier_contract_addr = IBukSupplierDeployer(supplier_deployer).deploySupplier(_contract_name, _supplierIds,_name, _supplier_owner, utility_contract_addr, _contract_uri);
        ISupplierContractUtility(utility_contract_addr).grantSupplierRole(supplier_contract_addr);
        Suppliers[_supplierIds].id = _supplierIds;
        Suppliers[_supplierIds].status = true;
        Suppliers[_supplierIds].supplier_contract = supplier_contract_addr;
        Suppliers[_supplierIds].supplier_owner = _supplier_owner;
        Suppliers[_supplierIds].utility_contract = utility_contract_addr;
        emit RegisterSupplier(_supplierIds, supplier_contract_addr, utility_contract_addr);
    }

    /** 
    * @dev Function to book rooms.
    * @param _supplierId ID of the supplier.
    * @param _count Number of rooms to be booked.
    * @param _total Total amount to be paid.
    * @param _baseRate Base rate of the room.
    * @param _checkin Checkin date.
    * @param _checkout Checkout date.
    * @return ids IDs of the bookings.
    * @notice Only registered Suppliers' rooms can be booked.
    */
    function bookRoom(uint256 _supplierId, uint256 _count, uint256[] memory _total, uint256[] memory _baseRate, uint256 _checkin, uint256 _checkout) nonReentrant() external returns (bool) {
        require(Suppliers[_supplierId].status, "Supplier not registered");
        uint256[] memory bookings = new uint256[](_count);
        uint total = 0;
        uint commissionTotal = 0;
        for(uint8 i=0; i<_count;++i) {
            ++_bookingIds;
            BookingDetails[_bookingIds] = Booking(_bookingIds, BookingStatus.booked, 0, _msgSender(), _supplierId, _checkin, _checkout, _total[i], _baseRate[i]);
            bookings[i] = _bookingIds;
            total+=_total[i];
            commissionTotal+= _baseRate[i]*commission/100;
            emit BookRoom(_bookingIds);
        }
        bool collectCommission = IERC20(currency).transferFrom(_msgSender(), buk_wallet, commissionTotal);
        if(collectCommission) {
            bool collectPayment = IERC20(currency).transferFrom(_msgSender(), treasury, total);
            if(collectPayment) {
                emit BookRooms(bookings, total, commissionTotal);
                return true;
            } else {
                IERC20(currency).transferFrom(buk_wallet, _msgSender(), commissionTotal);
                IERC20(currency).transferFrom(treasury, _msgSender(), total);
                return false;
            }
        } else {
            IERC20(currency).transferFrom(buk_wallet, _msgSender(), commissionTotal);
            return false;
        }
    }

    /** 
    * @dev Function to refund the amount for the failure scenarios.
    * @param _supplierId ID of the supplier.
    * @param _ids IDs of the bookings.
    * @notice Only registered Suppliers' rooms can be booked.
    */
    function bookingRefund(uint256 _supplierId, uint256[] memory _ids, address _owner) external onlyRole(ADMIN_ROLE) {
        require(Suppliers[_supplierId].status, "Supplier not registered");
        uint256 len = _ids.length;
        for(uint8 i=0; i<len; ++i) {
            require(BookingDetails[_ids[i]].status == BookingStatus.booked, "Check the Booking status");
        }
        for(uint8 i=0; i<len; ++i) {
            require(BookingDetails[_ids[i]].owner == _owner, "Check the booking owner");
        }
        uint total = 0;
        for(uint8 i=0; i<len;++i) {
            BookingDetails[_ids[i]].status = BookingStatus.cancelled;
            total+= BookingDetails[_ids[i]].total + BookingDetails[_ids[i]].baseRate*commission/100;
        }
        ITreasury(treasury).cancelUSDCRefund(total, _owner);
        emit BookingRefund(total, _owner);
    }
    
    /**
    * @dev Function to confirm the room bookings.
    * @param _supplierId ID of the supplier.
    * @param _ids IDs of the bookings.
    * @param _uri URIs of the NFTs.
    * @param _status Status of the NFT.
    * @notice Only registered Suppliers' rooms can be confirmed.
    * @notice Only the owner of the booking can confirm the rooms.
    * @notice The number of bookings and URIs should be same.
    * @notice The booking status should be booked to confirm it.
    * @notice The NFTs are minted to the owner of the booking.
    */
    function confirmRoom(uint256 _supplierId, uint256[] memory _ids, string[] memory _uri, bool _status) nonReentrant() external {
        require(Suppliers[_supplierId].status, "Supplier not registered");
        uint256 len = _ids.length;
        for(uint8 i=0; i<len; ++i) {
            require(BookingDetails[_ids[i]].status == BookingStatus.booked, "Check the Booking status");
            require(BookingDetails[_ids[i]].owner == _msgSender(), "Only booking owner has access");
        }
        require((len == _uri.length), "Check Ids and URIs size");
        require((len < 11), "Exceeds max room booking limit");
        ISupplierContract _SupplierContract = ISupplierContract(Suppliers[_supplierId].supplier_contract);
        for(uint8 i=0; i<len; ++i) {
            BookingDetails[_ids[i]].status = BookingStatus.confirmed;
            _SupplierContract.mint(_ids[i], BookingDetails[_ids[i]].owner, 1, "", _uri[i], _status);
            BookingDetails[_ids[i]].tokenID = _ids[i];
        }
        emit ConfirmRooms(_ids, true);
    }

    /**
    * @dev Function to checkout the rooms.
    * @param _supplierId ID of the supplier.
    * @param _ids IDs of the bookings.
    * @notice Only registered Suppliers' rooms can be checked out.
    * @notice Only the admin can checkout the rooms.
    * @notice The booking status should be confirmed to checkout it.
    * @notice The Active Booking NFTs are burnt from the owner's account.
    * @notice The Utility NFTs are minted to the owner of the booking.
    */
    function checkout(uint256 _supplierId, uint256[] memory _ids ) external onlyRole(ADMIN_ROLE)  {
        require(Suppliers[_supplierId].status, "Supplier not registered");
        uint256 len = _ids.length;
        require((len < 11), "Exceeds max room booking limit");
        for(uint8 i=0; i<len; ++i) {
            require(BookingDetails[_ids[i]].status == BookingStatus.confirmed, "Check the Booking status");
        }
        for(uint8 i=0; i<len;++i) {
            BookingDetails[_ids[i]].status = BookingStatus.expired;
            ISupplierContract(Suppliers[_supplierId].supplier_contract).burn(BookingDetails[_ids[i]].owner, _ids[i], 1, true);
        }
        emit CheckoutRooms(_ids, true);
    }

    /** 
    * @dev Function to cancel the room bookings.
    * @param _supplierId ID of the supplier.
    * @param _id ID of the booking.
    * @param _penalty Penalty amount to be refunded.
    * @param _refund Refund amount to be refunded.
    * @param _charges Charges amount to be refunded.
    * @notice Only registered Suppliers' rooms can be cancelled.
    * @notice Only the admin can cancel the rooms.
    * @notice The booking status should be confirmed to cancel it.
    * @notice The Active Booking NFTs are burnt from the owner's account.
    */
    function cancelRoom(uint256 _supplierId, uint256 _id, uint256 _penalty, uint256 _refund, uint256 _charges ) external onlyRole(ADMIN_ROLE) {
        require(Suppliers[_supplierId].status, "Supplier not registered");
        require((BookingDetails[_id].status == BookingStatus.confirmed), "Supplier not registered");
        ISupplierContract _SupplierContract = ISupplierContract(Suppliers[_supplierId].supplier_contract);
        BookingDetails[_id].status = BookingStatus.cancelled;
        ITreasury(treasury).cancelUSDCRefund(_penalty, Suppliers[BookingDetails[_id].supplierId].supplier_owner);
        ITreasury(treasury).cancelUSDCRefund(_refund, BookingDetails[_id].owner);
        ITreasury(treasury).cancelUSDCRefund(_charges, buk_wallet);
        _SupplierContract.burn(BookingDetails[_id].owner, _id, 1, false);
        emit CancelRoom(_id, true);
    }
}
