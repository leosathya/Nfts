// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contract Address :: 0xda4B27Cb9c4B6DCE2009B6E056B4122d210003Ab

contract OnchainNft is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
   struct Word { 
      string name;
      string description;
      string bgHue;
      string textHue;
      string value;
   }

  
  mapping (uint256 => Word) public words; 
  
  constructor() ERC721("Onchain Nft by SD", "SDN") {}

  // public
  function mint(string memory _yourName) public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 1000);
    
    Word memory newWord = Word(
        string(abi.encodePacked('Nft Sl #', uint256(supply + 1).toString())), 
        "Pretty Awesome Words are all you need to feel good. These NFTs are there to inspire and uplift your spirit.",
        randomNum(361, block.difficulty, supply).toString(),
        randomNum(361, block.timestamp, supply).toString(),
        //wordsValues[randomNum(wordsValues.length, block.difficulty, supply)]);
        _yourName
    );

    if (msg.sender != owner()) {
      require(msg.value >= 0.005 ether);
    }
    
    words[supply + 1] = newWord;
    _safeMint(msg.sender, supply + 1);
  }

  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }
  
  function buildImage(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return encode(bytes(
          abi.encodePacked(
              '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
              '<rect height="500" width="500" fill="hsl(',currentWord.bgHue,', 50%, 25%)"/>',
              '<text x="50%" y="50%" dominant-baseline="middle" fill="hsl(',currentWord.textHue,', 100%, 80%)" text-anchor="middle" font-size="41">',currentWord.value,'</text>',
              '</svg>'
          )
      ));
  }
  
  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          currentWord.name,
                          '", "description":"', 
                          currentWord.description,
                          '", "image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '"}')))));
  }

  function tokenURI(uint256 _tokenId) public view override returns(string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
  }

  function withdraw() public payable onlyOwner {

    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }

  function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';
        
        // load the table into memory
        string memory table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)
            
            // prepare the lookup table
            let tablePtr := add(table, 1)
            
            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            // result ptr, jump over length
            let resultPtr := add(result, 32)
            
            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               // read 3 bytes
               let input := mload(dataPtr)
               
               // write 4 characters
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
}