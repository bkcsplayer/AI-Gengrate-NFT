// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping (address => uint256) private _mintedTokens;

    address public owner;
    uint256 public cost;
    uint256 public totalSupplyLimit = 10000;
    mapping (address => bool) public whitelist;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cost
    ) ERC721(_name, _symbol) {
        owner = msg.sender;
        cost = _cost;
    }

    function mint(string memory tokenURI) public payable {
        require(msg.value >= cost);
        require(whitelist[msg.sender]);
        require(_mintedTokens[msg.sender] < 2);
        require(_tokenIds.current() < totalSupplyLimit);

        _tokenIds.increment();
        _mintedTokens[msg.sender]++;

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function addToWhitelist(address _address) public {
        require(msg.sender == owner);
        whitelist[_address] = true;
    }

    function withdraw() public {
        require(msg.sender == owner);
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
