const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Consignment Testing', async () => {
  let consignment;
  let owner;
  let nonOwner;

  before(async () => {
    [owner, nonOwner] = await ethers.getSigners();
    const Consignment = await ethers.getContractFactory('Consignment');
    consignment = await Consignment.deploy(owner.address);
  });

  describe('Deployment', async () => {
    it('should deployed', async function () {
      expect(consignment.address).to.not.equal('');
    });
  });

  describe('Testing URI functions', async () => {
    it('should set contract URI', async () => {
      await consignment.setBaseURI('ipfs://qm6yUiaiak');

      expect(await consignment.baseTokenURI()).to.eq('ipfs://qm6yUiaiak');
    });
  });

  describe('Testing Fill Stock Function', async () => {
    it('should fill stock', async () => {
      let id = 1;
      let quantity = 10;
      let to = nonOwner.address;

      const receipt = await (await consignment.fillStock(to, id, quantity)).wait();
      const fillStock = receipt.events?.[1];

      expect(await consignment.balanceOf(to, 1)).to.eq(ethers.BigNumber.from('10'));
      expect(fillStock?.event).to.eq('FillStock');
      expect(fillStock?.args?.to).to.eq(to);
      expect(fillStock?.args?.id).to.eq(id);
      expect(fillStock?.args?.quantity).to.eq(quantity);
    });

    it('should fill stock batch', async () => {
      let to = nonOwner.address;
      let ids = [2, 3];
      let quantities = [10, 10];

      const receipt = await (await consignment.fillStockBatch(to, ids, quantities)).wait();
      const fillStockBatch = receipt.events?.[1];

      // expect(await consignment.balanceOfBatch([to, to], ids)[0]).to.eq([
      //   ethers.BigNumber.from('10'),
      //   ethers.BigNumber.from('10'),
      // ]);

      expect(await consignment.balanceOf(to, 2)).to.eq(ethers.BigNumber.from('10'));
      expect(await consignment.balanceOf(to, 3)).to.eq(ethers.BigNumber.from('10'));
      expect(fillStockBatch?.event).to.eq('FillStockBatch');
      // expect(fillStockBatch?.args?.to).to.eq(to);
      // expect(fillStockBatch?.args?.ids).to.eq(ids);
      // expect(fillStockBatch?.args?.quantities).to.eq(quantities);
    });
  });
});
