// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract PoCNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(bytes32 => bool) public mintedHashes;

    constructor() ERC721("ProofOfContribution", "POC") Ownable(msg.sender) {}

    function mint(string memory contributor, string memory repo, string memory summary) public {
        bytes32 hash = keccak256(abi.encodePacked(contributor, repo, summary));
        require(!mintedHashes[hash], "Already minted for this contribution");

        _tokenIds.increment();
        uint256 newId = _tokenIds.current();

        string memory json = Base64.encode(
            bytes(string(abi.encodePacked(
                '{"name": "PoC NFT #', _toString(newId),
                '", "description": "Proof of Contribution NFT", "attributes": [',
                '{"trait_type": "Contributor", "value": "', contributor,
                '"}, {"trait_type": "Repo", "value": "', repo,
                '"}, {"trait_type": "Summary", "value": "', summary,
                '"}]}'
            )))
        );

        string memory finalTokenURI = string(abi.encodePacked("data:application/json;base64,", json));
        _safeMint(msg.sender, newId);
        _setTokenURI(newId, finalTokenURI);

        mintedHashes[hash] = true;
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
