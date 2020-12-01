const VyperStorage = artifacts.require("VyperStorage");

contract("VyperStorage", () => {
  it("...should store the value 89.", async () => {
    const storage = await VyperStorage.deployed();

    // Set value of 89
    await storage.set(89);
    await storage.setRubyBalance(89);
    await storage.setEssenceBalance(89);

    // Get stored value
    const storedData = await storage.get();
    const ruby = await storage.getRubyBalance();
    const ess = await storage.getEssenceBalance();

    assert.equal(storedData, 89, "The value 89 was not stored.");
    assert.equal(ruby, 89, "ruby failed");
    assert.equal(ess, 89, "ess failed");
  });
});
