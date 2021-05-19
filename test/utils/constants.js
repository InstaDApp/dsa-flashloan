// External Address
const TOKEN_ADDR = {
  USDC: {
    contract: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    holder: "0xbe0eb53f46cd790cd13851d5eff43d12404d33e8",
  },
  WETH: {
    contract: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    holder: "0xc564ee9f21ed8a2d8e7e76c085740d5e4c5fafbe",
  },
  DAI: {
    contract: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    holder: "0xf977814e90da44bfa03b6295a0616a897441acec",
  },
  USDT: {
    contract: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    holder: "0x5754284f345afc66a98fbb0a0afe71e0f007b949",
  },
};
const MAX_VALUE =
  "115792089237316195423570985008687907853269984665640564039457584007913129639935";

// INSTA Address
const M1_ADDR = "0xFE2390DAD597594439f218190fC2De40f9Cf1179";
const INDEX_ADDR = "0x2971AdFa57b20E5a416aE5a708A8655A9c74f723";
const INSTA_IMPL_ADDR = "0xCBA828153d3a85b30B5b912e1f2daCac5816aE9D";

module.exports = {
  TOKEN_ADDR,
  MAX_VALUE,
  M1_ADDR,
  INDEX_ADDR,
  INSTA_IMPL_ADDR,
};
