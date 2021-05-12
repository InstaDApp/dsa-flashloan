pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import { Variables } from "./variables.sol";
interface TokenInterface {
    function transfer(address, uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
}

/**
 * @title InstaAccountV2.
 * @dev DeFi Smart Account Wallet.
 */

interface ConnectorsInterface {
    function isConnectors(string[] calldata connectorNames) external view returns (bool, address[] memory);
}

interface FlashloanInterface {
    function initiateFlashLoan(	
        address token,	
        uint256 amount,	
        bytes calldata data	
    ) external;
}

contract Constants is Variables {
    // InstaIndex Address.
    address internal immutable instaIndex;
    // Connnectors Address.
    address public immutable connectorsM1;
    // Connnectors Address.
    address public immutable flashloan;

    constructor(address _instaIndex, address _connectors, address _flashloan) {
        connectorsM1 = _connectors;
        instaIndex = _instaIndex;
        flashloan = _flashloan;
    }
}

contract InstaImplementationM2 is Constants {

    constructor(address _instaIndex, address _connectors, address _flashloan) Constants(_instaIndex, _connectors, _flashloan) {}

    function decodeEvent(bytes memory response) internal pure returns (string memory _eventCode, bytes memory _eventParams) {
        if (response.length > 0) {
            (_eventCode, _eventParams) = abi.decode(response, (string, bytes));
        }
    }

    event LogCast(
        address indexed origin,
        address indexed sender,
        uint256 value,
        string[] targetsNames,
        address[] targets,
        string[] eventNames,
        bytes[] eventParams
    );

    event LogFlashCast(
        address indexed origin,
        address tokens,
        uint256 amount
    );

    receive() external payable {}

     /**
     * @dev Delegate the calls to Connector.
     * @param _target Connector address
     * @param _data CallData of function.
    */
    function spell(address _target, bytes memory _data) internal returns (bytes memory response) {
        require(_target != address(0), "target-invalid");
        assembly {
            let succeeded := delegatecall(gas(), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize()
            
            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
    }

    /**
     * @dev This is similar to cast on implementation_m1
     * @param _targetNames Array of Connector address.
     * @param _datas Array of Calldata.
    */
    function flashCallback(
        address sender,
        address _token,
        uint256 _amount,
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    )
    external
    payable 
    {   
        uint256 _length = _targetNames.length;
        require(_auth[sender], "2: not-an-owner");
        require(msg.sender == flashloan, "2: not-flashloan-contract");
        require(_length != 0, "2: length-invalid");
        require(_length == _datas.length , "2: array-length-invalid");

        string[] memory eventNames = new string[](_length);
        bytes[] memory eventParams = new bytes[](_length);

        (bool isOk, address[] memory _targets) = ConnectorsInterface(connectorsM1).isConnectors(_targetNames);

        require(isOk, "1: not-connector");

        for (uint i = 0; i < _length; i++) {
            bytes memory response = spell(_targets[i], _datas[i]);
            (eventNames[i], eventParams[i]) = decodeEvent(response);
        }

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(flashloan).transfer(_amount);
        } else {
            require(TokenInterface(_token).transfer(flashloan, _amount), "flashloan-transfer-failed"); // TODO: Try catch: If fails then transfer 0.00000001% less?
        }

        emit LogCast(
            _origin,
            sender,
            msg.value,
            _targetNames,
            _targets,
            eventNames,
            eventParams
        );
    }

    function flashCast(
        address _token,
        uint256 _amount,
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external {
        bytes memory data = abi.encode(_targetNames, _datas, msg.sender);

        FlashloanInterface(flashloan).initiateFlashLoan(_token, _amount, data);

        emit LogFlashCast(_origin, _token, _amount);
    }

}