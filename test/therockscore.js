const TheRocksCore = artifacts.require('TheRocksCore');

contract('TheRocksCore', (accounts) => {
  let theRockCore;

  const owner = accounts[0];
  const character = 1;
  const delay = 0;

  beforeEach(async () => {
    theRockCore = await TheRocksCore.new();
  });

  it('should spawn a rock correctly', async () => {
    const setspawner = await theRockCore.setSpawner(accounts[0], true);
    const result = await theRockCore.spawnRock(character, owner, delay);
    let rockId = undefined;
    // Assert the rock details after spawning
    for (let e of result.logs) {
        // console.log(e);
        if(e.event === "RockSpawned") {
            console.log(e.event)
            rockId = e.args._rockId;
        }
    }
    // const rockId = result.logs[1].args._rockId;
    const rock = await theRockCore.getRock(rockId);
    const ownerOfRock = await theRockCore.ownerOf(rockId);

    assert.equal(rock.character, character);
    assert.equal(rock.exp, 0);
    assert.equal(rock.level, 0);
    assert.equal(ownerOfRock, owner);
  });
});
