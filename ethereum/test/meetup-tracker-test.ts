import { BigNumberish } from "ethers";
import { loadFixture, ethers, SignerWithAddress, expect } from "../setup";
import type { Meetup, MeetupTracker } from "../typechain-types";

describe("MeetupTracker", function () {
  let title: string = "The Scaling Meetup";
  let city: string = "Tbilisi";
  let startsDate: BigNumberish = ethers.BigNumber.from(1685037600); //25.05.2023-18:00
  let endsDate: BigNumberish = ethers.BigNumber.from(1685048400); //25.05.2023-21:00
  let index0: BigNumberish = ethers.BigNumber.from(0);

  let newTitle: string = "The Scaling Meetup V2";

  async function deploy() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MeetupTrackerFactory = await ethers.getContractFactory("MeetupTracker");
    const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
    await meetupTracker.deployed();

    const firstMeetupCreated: any = await meetupTracker
      .connect(deployer)
      .createMeetup(title, city, startsDate, endsDate);
    const firstMeetupTx = await firstMeetupCreated.wait();

    return { meetupTracker, firstMeetupCreated, firstMeetupTx, deployer, user1, user2, user3 };
  }

  it("createdMeetup", async function () {
    const { meetupTracker, firstMeetupTx } = await loadFixture(deploy);

    const block = await ethers.provider.getBlock(firstMeetupTx.blockHash);
    const blockTime = block.timestamp;

    const firstMeetupInArray = await meetupTracker.meetups(index0);

    expect(firstMeetupInArray.meetup).to.eq(firstMeetupTx.events[2].args[2]);
    expect(firstMeetupInArray.title).to.eq(title);
    expect(firstMeetupInArray.index).to.eq(index0);
    expect(firstMeetupInArray.isActive).to.eq(true);
    expect(firstMeetupInArray.timeCreated).to.eq(blockTime);
  });

  it("changeMeetupTitle", async function () {
    const { meetupTracker, deployer, user1 } = await loadFixture(deploy);

    await expect(
      meetupTracker.connect(user1).changeMeetupTitle(index0, newTitle, user1.address)
    ).to.be.revertedWith("You are not an owner!");

    await expect(
      meetupTracker.connect(deployer).changeMeetupTitle(index0, newTitle, deployer.address)
    ).to.not.be.reverted;

    expect((await meetupTracker.meetups(index0)).title).to.eq(newTitle);
  });

  it("closeMeetupByIndex", async function () {
    const { meetupTracker, deployer, user1 } = await loadFixture(deploy);

    await expect(
      meetupTracker.connect(user1).closeMeetupByIndex(index0, user1.address)
    ).to.be.revertedWith("You are not an owner!");

    await expect(meetupTracker.connect(deployer).closeMeetupByIndex(index0, deployer.address)).to
      .not.be.reverted;

    await expect((await meetupTracker.meetups(index0)).isActive).to.eq(false);

    await expect(
      meetupTracker.connect(deployer).closeMeetupByIndex(index0, deployer.address)
    ).to.be.revertedWith("Meetup already closed!");
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
