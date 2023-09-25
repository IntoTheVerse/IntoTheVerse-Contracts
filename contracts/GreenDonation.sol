//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TreeContract.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GreenDonation is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    event TreeNurtured(
        uint256 tokenId,
        uint256 amount,
        address tokenAddress,
        uint256 _treeL
    );

    struct User {
        uint256 lastSnapshot;
        uint256 unclaimedRewards;
        EnumerableSet.UintSet trees;
    }

    address public treeContractAddress;
    EnumerableSet.AddressSet internal acceptedTokens;
    mapping(address => uint256) public yieldPerToken;
    //key is keccack256(address, tokenAddress)
    mapping(bytes => uint256) public stakes;
    mapping(address => User) internal users;

    constructor(
        address _treeContractAddress,
        address[] memory _acceptedTokens
    ) {
        treeContractAddress = _treeContractAddress;
        for (uint256 i = 0; i < _acceptedTokens.length; i++) {
            acceptedTokens.add(_acceptedTokens[i]);
        }
    }

    function nurtureTree(
        uint256 _tokenId,
        uint256 _amount,
        address _tokenAddress
    ) external {
        require(acceptedTokens.contains(_tokenAddress), "Token not accepted");
        IERC20(msg.sender).transferFrom(msg.sender, address(this), _amount);
        TreeContract(treeContractAddress).waterTree(_tokenId);
        bytes memory key = abi.encodePacked(msg.sender, _tokenAddress);
        stakes[key] += _amount;

        uint256 rewards = calculateRewards(msg.sender);
        users[msg.sender].unclaimedRewards = rewards;
        users[msg.sender].lastSnapshot = block.timestamp;
        users[msg.sender].trees.add(_tokenId);

        emit TreeNurtured(_tokenId, _amount, _tokenAddress, 0);
    }

    //define yield per token
    function setYieldPerToken(
        address _tokenAddress,
        uint256 _yield
    ) external onlyOwner {
        yieldPerToken[_tokenAddress] = _yield;
    }

    //add new token to accepted tokens
    function addAcceptedToken(address _tokenAddress) external onlyOwner {
        acceptedTokens.add(_tokenAddress);
    }

    //remove token from accepted tokens
    function removeAcceptedToken(address _tokenAddress) external onlyOwner {
        acceptedTokens.remove(_tokenAddress);
    }

    //change tree contract address
    function setTreeContractAddress(
        address _treeContractAddress
    ) external onlyOwner {
        treeContractAddress = _treeContractAddress;
    }

    //withdraw tokens
    function withdrawTokens(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    //calculate rewards, yield rate is a daily rate
    function calculateRewards(
        address _userAddress
    ) public view returns (uint256) {
        uint256 yield = 0;
        for (uint256 i = 0; i < acceptedTokens.length(); i++) {
            address tokenAddress = acceptedTokens.at(i);
            bytes memory key = abi.encodePacked(_userAddress, tokenAddress);
            uint256 userStake = stakes[key];
            uint256 yieldRate = yieldPerToken[tokenAddress];
            yield += userStake * yieldRate;
        }

        uint256 unclaimedRewards = users[_userAddress].unclaimedRewards;
        uint256 lastSnapshot = users[_userAddress].lastSnapshot;

        uint256 timePassed = block.timestamp - lastSnapshot;
        uint256 yieldPerSecond = yield / 86400;
        uint256 newRewards = timePassed * yieldPerSecond;
        return unclaimedRewards + newRewards;
    }

    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender);
        users[msg.sender].unclaimedRewards = 0;
        users[msg.sender].lastSnapshot = block.timestamp;
        //TODO a percentage needs to go to TOUCAN PROTOCOL
        IERC20(msg.sender).transfer(msg.sender, rewards);
    }

    // refund all stakes for a user while claiming their rewards at the same time
    function unstake() external {
        uint256 rewards = calculateRewards(msg.sender);
        users[msg.sender].unclaimedRewards = 0;
        users[msg.sender].lastSnapshot = block.timestamp;
        //TODO a percentage needs to go to TOUCAN PROTOCOL
        IERC20(msg.sender).transfer(msg.sender, rewards);

        for (uint256 i = 0; i < acceptedTokens.length(); i++) {
            address tokenAddress = acceptedTokens.at(i);
            bytes memory key = abi.encodePacked(msg.sender, tokenAddress);
            uint256 userStake = stakes[key];
            stakes[key] = 0;
            IERC20(tokenAddress).transfer(msg.sender, userStake);
        }

        EnumerableSet.UintSet storage userTrees = users[msg.sender].trees;
        for (uint256 i = 0; i < userTrees.length(); i++) {
            uint256 lastWatered = TreeContract(treeContractAddress)
                .getLastWatered(userTrees.at(i));
            if (block.timestamp - lastWatered > 1 weeks) {
                TreeContract(treeContractAddress).downgradeTree(
                    userTrees.at(i)
                );
            }
        }

        delete users[msg.sender];
    }
    
}
