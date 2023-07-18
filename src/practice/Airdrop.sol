// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

//  ==========  External imports    ==========

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//  ==========  Libraries    ==========

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library CurrencyTransferLib {
    using SafeERC20 for IERC20;

    /// @dev The address interpreted as native token of the chain.
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev Transfers a given amount of currency.
    function transferCurrency(address _currency, address _from, address _to, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        safeTransferERC20(_currency, _from, _to, _amount);
    }

    /// @dev Transfer `amount` of ERC20 token from `from` to `to`.
    function safeTransferERC20(address _currency, address _from, address _to, uint256 _amount) internal {
        if (_from == _to) {
            return;
        }

        if (_from == address(this)) {
            IERC20(_currency).safeTransfer(_to, _amount);
        } else {
            IERC20(_currency).safeTransferFrom(_from, _to, _amount);
        }
    }
}

contract AirdropERC20 is Ownable, ReentrancyGuard, Multicall {
    /*///////////////////////////////////////////////////////////////
                            State variables
    //////////////////////////////////////////////////////////////*/

    bytes32 private constant MODULE_TYPE = bytes32("AirdropERC20");
    uint256 private constant VERSION = 1;

    /*///////////////////////////////////////////////////////////////
                    Constructor + initializer logic
    //////////////////////////////////////////////////////////////*/

    constructor() {}

    /*///////////////////////////////////////////////////////////////
                        Generic contract logic
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the type of the contract.
    function contractType() external pure returns (bytes32) {
        return MODULE_TYPE;
    }

    /// @dev Returns the version of the contract.
    function contractVersion() external pure returns (uint8) {
        return uint8(VERSION);
    }

    /*///////////////////////////////////////////////////////////////
                            Airdrop logic
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice          Lets contract-owner send ERC20 tokens to a list of addresses.
     *  @dev             The token-owner should approve target tokens to Airdrop contract,
     *                   which acts as operator for the tokens.
     *
     *  @param _tokenAddress    Contract address of ERC20 tokens to air-drop.
     *  @param _tokenOwner      Address from which to transfer tokens.
     *  @param _recipients      List of recipient addresses for the air-drop.
     *  @param _amounts         Quantity of tokens to air-drop, per recipient.
     */
    function airdrop(
        address _tokenAddress,
        address _tokenOwner,
        address[] memory _recipients,
        uint256[] memory _amounts
    ) external payable nonReentrant onlyOwner {
        uint256 len = _amounts.length;
        require(len == _recipients.length, "length mismatch");

        if (_tokenAddress == CurrencyTransferLib.NATIVE_TOKEN) {
            uint256 totalAmount;
            for (uint256 i = 0; i < len; i++) {
                totalAmount += _amounts[i];
            }
            require(totalAmount == msg.value, "Incorrect native token amount");
        }

        for (uint256 i = 0; i < len; i++) {
            CurrencyTransferLib.transferCurrency(_tokenAddress, _tokenOwner, _recipients[i], _amounts[i]);
        }
    }
}
