import { loadFixture, ethers, SignerWithAddress, expect, BigNumberish } from "../setup";
import type { Meetup, MeetupTracker } from "../typechain-types";

describe("Meetup", function () {
  let title: string = "The First Meetup";
  let city: string = "Oslo";
  let startsDate: BigNumberish = ethers.BigNumber.from(1685037600); //25.05.2023-18:00
  let endsDate: BigNumberish = ethers.BigNumber.from(1685048400); //25.05.2023-21:00

  async function deploy() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MeetupTrackerFactory = await ethers.getContractFactory("MeetupTracker");
    const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
    await meetupTracker.deployed();

    const firstMeetupCreated: any = await meetupTracker
      .connect(deployer)
      .createMeetup(title, city, startsDate, endsDate);

    const firstMeetupTx = await firstMeetupCreated.wait();

    const meetupAddress = firstMeetupTx.events[2].args[2];

    console.log(meetupAddress);

    const MeetupFactory = await ethers.getContractFactory("Meetup");
    const meetup: Meetup = await MeetupFactory.attach(meetupAddress);

    return { meetupTracker, meetup, deployer, user1, user2, user3 };
  }

  it("doDonate", async function () {
    const { meetup, deployer, user1 } = await loadFixture(deploy);
    await expect(meetup.connect(user1)["reg(string)"]("Dima")).to.not.be.reverted;

    await expect(meetup.doDonate(0)).to.be.revertedWith("Donation can't be less than zero");

    await expect(meetup.connect(user1).doDonate(100)).to.to.not.be.reverted;
  });
});
