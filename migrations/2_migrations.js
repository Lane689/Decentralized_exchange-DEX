const Hello = artifacts.require("Helloworld");

module.exports = function(deployer){
    deployer.deploy(Hello);
}