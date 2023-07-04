// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract SmartContractWalletImpl {
    address payable public owner;
    mapping(address => uint256) public allowance;
    mapping(address => bool) public isAllowedToSend;
    mapping(address => bool) public guardian;
    address payable nextOwner;
    mapping(address => mapping(address => bool))
        public nextOwnerGuarduanVoteBool;

    uint256 guardianResetCount;
    uint256 public constant confirmFromGudForReset = 3;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable{}

  

    function proposeNewOwner(address payable _newOwner) public {
        require(guardian[msg.sender], "Not a guardian");
        require(
            nextOwnerGuarduanVoteBool[_newOwner][msg.sender] == false,
            "You already Voted"
        );

        if (_newOwner != nextOwner) {
            nextOwner = _newOwner;
            guardianResetCount = 0;
        }
        guardianResetCount++;

        if (guardianResetCount >= confirmFromGudForReset) {
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setGuardian(address _guardian, bool _isGuardian) public {
        require(msg.sender == owner, "You are not the owner");
        guardian[_guardian] = _isGuardian;
    }

    function setAllowance(address _for, uint256 _amt) public {
        require(msg.sender == owner, "You are not the owner");
        allowance[_for] = _amt;

        if (_amt > 0) {
            isAllowedToSend[_for] = true;
        } else {
            isAllowedToSend[_for] = true;
        }
    }

    function transfer(
        address payable _to,
        uint256 _amount,
        bytes memory _payload
    ) public returns (bytes memory) {
        if (msg.sender != owner) {
            require(
                isAllowedToSend[msg.sender],
                "U are NOT allowed to send anything"
            );
            require(allowance[msg.sender] >= _amount, "Insufficient Funds");
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(
            _payload
        );
        require(success);
        return returnData;
    }
}


contract Consumer 
{
    function getBal() public view returns(uint)
    {
        return address(this).balance;

    }

    function deposit() public payable {}
}