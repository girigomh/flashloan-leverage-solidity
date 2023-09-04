module.exports = {
  istanbulReporter: ['html', 'lcov', 'text', 'json'],
  configureYulOptimizer: true,
  skipFiles: ["test", "mock", "interfaces", "/core/ChainlinkPriceProvider.sol"],
};
