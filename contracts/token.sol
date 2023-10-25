// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20Capped, Ownable {
    constructor() ERC20("BeSmart", "BSC") ERC20Capped(150000) {
        // additional functionallity if we need 
        _mint(msg.sender, 1000);
    }

    // extenzije burnable bez inheritanja, because burnable i capped are inheriting ERC20.sol (doble inheritance, lverriding functions,...)

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    // this function is for allowance, if needed
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}