const Unipay = artifacts.require('Unipay');

contract('Unipay', accounts => {
  it('smells like unicorn', () => {
    expect(Unipay).not.to.equal(undefined);
  });
});
