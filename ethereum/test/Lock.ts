//import { MeetupTracker } from './../typechain-types/contracts/MeetupTracker';
import { loadFixture, ethers, SignerWithAddress, expect } from "../setup";
import type { Events, Meetup, MeetupTracker } from "../typechain-types";

describe("MeetupTracker", function () {
  async function deploy() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MeetupTrackerFactory = await ethers.getContractFactory(
      "MeetupTracker"
    );
    const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
    await meetupTracker.deployed();

    return { meetupTracker, deployer, user1, user2, user3 };
  }

  it("allows", async function () {
    const { meetupTracker, deployer } = await loadFixture(deploy);

    expect(await meetupTracker.owner()).to.eq(deployer.address);
  });

  // it("allows to call pay() and message()", async function() {
  //   const { sample, deployer } = await loadFixture(deploy);

  //   const value = 1000;
  //   const tx = await sample.pay("hi", {value: value});
  //   await tx.wait();

  //   expect(await sample.get()).to.eq(value);
  //   expect(await sample.message()).to.eq("hi");
  // });

  // it("allows to call callMe()", async function() {
  //   const { sample, user } = await loadFixture(deploy);

  //   const sampleAsUser = Sample__factory.connect(sample.address, user);
  //   const tx = await sampleAsUser.callMe();
  //   await tx.wait();

  //   expect(await sampleAsUser.caller()).to.eq(user.address);
  // });

  // it("reverts call to callError() with Panic", async function() {
  //   const { sample, deployer } = await loadFixture(deploy);

  //   await expect(sample.callError()).to.be.revertedWithPanic();
  // });
});
