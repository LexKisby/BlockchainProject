// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {
    address private owner;
    mapping(address => bool) trustedAddresses;

    modifier isTrusted() {
        require(
            trustedAddresses[msg.sender] == true,
            "Request is not from a trusted source"
        );
        _;
    }

    function addTrusted(address _address) external isOwner() {
        trustedAddresses[_address] = true;
    }

    function removeTrusted(address _address) external isOwner() {
        trustedAddresses[_address] = false;
    }

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        trustedAddresses[owner] = true;
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function _getOwner() public view returns (address) {
        return owner;
    }
}
