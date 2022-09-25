// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract Consignment is ERC1155, Pausable, Ownable, ERC1155Supply {
    event FillStock(address indexed to, uint256 id, uint256 quantity);
    event FillStockBatch(address indexed to, uint256[] ids, uint256[] quantities);

    event ReturnStock(address indexed from, uint256 id, uint256 quantity);
    event ReturnStockBatch(address indexed from, uint256[] ids, uint256[] quantities);

    event WriteoffStock(address indexed from, uint256 id, uint256 quantity);
    event WriteoffStockBatch(address indexed from, uint256[] ids, uint256[] quantities);

    string public baseTokenURI;

    constructor(string memory _baseTokenURI) ERC1155('') {
        baseTokenURI = _baseTokenURI;
    }

    // token URI
    function setBaseURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        require(exists(tokenId), 'Token does not exists !');
        return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId))) : '';
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // fill stock
    function fillStock(
        address to,
        uint256 id,
        uint256 quantity
    ) public whenNotPaused onlyOwner {
        _mint(to, id, quantity, '');
        emit FillStock(to, id, quantity);
    }

    function fillStockBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory quantities
    ) public whenNotPaused onlyOwner {
        _mintBatch(to, ids, quantities, '');
        emit FillStockBatch(to, ids, quantities);
    }

    // return
    function returnStock(uint256 id, uint256 quantity) public whenNotPaused {
        _burn(msg.sender, id, quantity);
        emit ReturnStock(msg.sender, id, quantity);
    }

    function returnStockBatch(uint256[] memory ids, uint256[] memory quantities) public virtual {
        _burnBatch(msg.sender, ids, quantities);
        emit ReturnStockBatch(msg.sender, ids, quantities);
    }

    // writeoff
    function writeoffStock(uint256 id, uint256 quantity) public whenNotPaused {
        _burn(msg.sender, id, quantity);
        emit WriteoffStock(msg.sender, id, quantity);
    }

    function writeoffStockBatch(uint256[] memory ids, uint256[] memory quantities) public virtual {
        _burnBatch(msg.sender, ids, quantities);
        emit WriteoffStockBatch(msg.sender, ids, quantities);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
