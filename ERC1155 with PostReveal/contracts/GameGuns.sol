// SPDX-License-Identifier: MIT

// 0xBDE183427644a6B5557aDbcF8669a88944EE97c7

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract GameGuns is ERC1155, Ownable {
    
  string public name;
  string public symbol;

  bool public revealed = false;
  string public notRevealedUri;

  mapping(uint => string) public tokenURI;

  constructor(string memory _name,
    string memory _symbol,string memory _initNotRevealedUri) ERC1155("") {
    name = _name;
    symbol = _symbol;
    setNotRevealedURI(_initNotRevealedUri);
  }

  function mint(address _to, uint _id, uint _amount) external onlyOwner {
    _mint(_to, _id, _amount, "");
  }

  function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
    _mintBatch(_to, _ids, _amounts, "");
  }

  function burn(uint _id, uint _amount) external {
    _burn(msg.sender, _id, _amount);
  }

  function burnBatch(uint[] memory _ids, uint[] memory _amounts) external {
    _burnBatch(msg.sender, _ids, _amounts);
  }

  function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) external onlyOwner {
    _burnBatch(_from, _burnIds, _burnAmounts);
    _mintBatch(_from, _mintIds, _mintAmounts, "");
  }

  function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }


// for public testing reveal im giving access of this function to public
  function reveal() public {
      revealed = !revealed;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function uri(uint _id) public override view returns (string memory) {
    if(revealed == false) {
        return notRevealedUri;
    }

    return tokenURI[_id];
  }

}