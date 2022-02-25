const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await waveContract.deployed();
  console.log("Contract deployed at:", waveContract.address);
  console.log("Contract deployed by:", owner.address);

  userToWaves = new Map();
  const addUserToMap = (address) => {
    let currentWave = userToWaves.get(address);
    if (currentWave == null) {
      userToWaves.set(address, 1);
    } else {
      userToWaves.set(address, currentWave + 1);
    }
  };

  let waveCount;
  waveCount = await waveContract.getTotalWaves();

  // getting contract balance
  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  // send wave
  let waveTxn = await waveContract.wave("This is wave #1");
  addUserToMap(waveTxn.from);
  await waveTxn.wait(); // wait for txn to be mined

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  // this is to test cooldown
  waveTxn = await waveContract.wave("Testing cooldown!");
  addUserToMap(waveTxn.from);
  await waveTxn.wait(); // wait for txn to be mined

  // for a msg from someone else then owner
  waveTxn = await waveContract.connect(randomPerson).wave("This is wave #2");
  addUserToMap(waveTxn.from);
  await waveTxn.wait(); // wait for txn to be mined

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  console.log("Count of Txns made:", userToWaves);

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit node process wwihtout error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
};

runMain();
