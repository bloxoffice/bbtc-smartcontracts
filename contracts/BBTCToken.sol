pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./Owned.sol";

contract BBTCToken is StandardToken, Owned {

    /* Constants */

    // Token Name
    string public constant name = "BloxOffice token";
    // Ticker Symbol
    string public constant symbol = "BBTC";
    // Decimals
    uint8 public constant decimals = 18;


    bool public tokenSaleClosed = false;


    /* Owners */

    // Ethereum address owner multisig wallet
    address public _fundowner = 0x13d7df226cf1119d4d81b7bc062c3d356a19b888;
    // Dev Team multisig wallet
    address public _devteam = 0x57f567C244E1378c02Bd9480E739fcc7e15069bb;
    // Advisors & Mentors multisig wallet
    address public _mentors = 0xEDD0CaE7C236f474672EfAC59Eb326235729f12b;
    //private Sale; multisig wallet
    address public _privateSale = 0x234c7F1C8Ea724ea5C40294f155a784577093520;

    /* Token Distribution */

    // Total supply of Tokens 999 Million
    uint256 public totalSupply = 999999999 * 10**uint256(decimals);
    // CrowdSale hard cap
    uint256 public TOKENS_SALE_HARD_CAP = 649999999 * 10**uint256(decimals);
    //Dev Team
    uint256 public DEV_TEAM = 240000000 * 10**uint256(decimals);
    //Mentors
    uint256 public MENTORS = 80000000 * 10**uint256(decimals);
    //Bounty
    uint256 public BOUNTY = 20000000 * 10**uint256(decimals);
    //Private Sale
    uint256 public PRIVATE = 10000000 * 10**uint256(decimals);


    //Private Sale
    uint64 private constant privateSaleDate = 1519756200;


    //Pre-sale Start Date
    uint64 private constant presaleStartDate = 1520015400;
    //Pre-sale End Date
    uint64 private constant preSaleStartDate = 1520101800;


    //CrowdSale Start Date
    uint64 private constant crowdSaleStart = 1520105400;
    //CrowdSale End Date
    uint64 private constant crowdSaleEnd = 1520188200;


    /* Base exchange rate is set to 1 ETH = 2500 BBTC */
    uint256 public constant BASE_RATE = 2500;

    /* Constructor */
    function BBTCToken(){

    }

    /// @return if the token sale is finished
      function saleDue() public view returns (bool) {
          return crowdSaleEnd < uint64(block.timestamp);
      }

    modifier inProgress {
        require(totalSupply < TOKENS_SALE_HARD_CAP
                && !tokenSaleClosed
                && !saleDue());
        _;
    }

    /// @dev This default function allows token to be purchased by directly
    /// sending ether to this smart contract.
    function () public payable {
        purchaseTokens(msg.sender);
    }

    /// @dev Issue token based on Ether received.
    /// @param _beneficiary Address that newly issued token will be sent to.
    function purchaseTokens(address _beneficiary) public payable inProgress {
        // only accept a minimum amount of ETH?
        //require(msg.value >= 0.01 ether);

        uint256 tokens = computeTokenAmount(msg.value);
        doIssueTokens(_beneficiary, tokens);

        /// forward the raised funds to the fund address
        _fundowner.transfer(msg.value);
    }


    /// @dev Compute the amount of ING token that can be purchased.
    /// @param ethAmount Amount of Ether to purchase ING.
    /// @return Amount of ING token to purchase
    function computeTokenAmount(uint256 ethAmount) internal view returns (uint256 tokens) {
        /// the percentage value (0-100) of the discount for each tier
        uint64 discountPercentage = currentTierDiscountPercentage();

        uint256 tokenBase = ethAmount.mul(BASE_RATE);
        uint256 tokenBonus = tokenBase.mul(discountPercentage).div(100);

        tokens = tokenBase.add(tokenBonus);
    }


    /// @dev Determine the current sale tier.
      /// @return the index of the current sale tier.
      function currentTierDiscountPercentage() internal view returns (uint64) {
          uint64 _now = uint64(block.timestamp);
          require(_now <= privateSaleDate);

          if(_now > crowdSaleEnd) return 0;
          if(_now > preSaleStartDate) return 10;
          if(_now > privateSaleDate) return 15;
          return 0;
      }

    /// @dev issue tokens for a single buyer
    /// @param _beneficiary addresses that the tokens will be sent to.
    /// @param _tokensAmount the amount of tokens, with decimals expanded (full).
    function doIssueTokens(address _beneficiary, uint256 _tokensAmount) internal {
        require(_beneficiary != address(0));

        // compute without actually increasing it
        uint256 increasedTotalSupply = totalSupply.add(_tokensAmount);
        // roll back if hard cap reached
        require(increasedTotalSupply <= TOKENS_SALE_HARD_CAP);

        // increase token total supply
        totalSupply = increasedTotalSupply;
        // update the buyer's balance to number of tokens sent
        balances[_beneficiary] = balances[_beneficiary].add(_tokensAmount);
    }


    /// @dev Returns the current price.
    function price() public view returns (uint256 tokens) {
      return computeTokenAmount(1 ether);
    }
  }
