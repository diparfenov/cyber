import { loadFixture, ethers, SignerWithAddress, expect, BigNumberish } from "../setup";
import { Meetup__factory, type Meetup, type MeetupTracker } from "../typechain-types";

describe("Meetup", function () {
  let title: string = "The First Meetup";
  let city: string = "Oslo";
  let startsDate: BigNumberish = ethers.BigNumber.from(1688999853); //10 Jul 2023 11:48:46 GMT
  let endsDate: BigNumberish = ethers.BigNumber.from(1689025053); // Jul 2023 21:48:46 GMT

  async function deploy() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MeetupTrackerFactory = await ethers.getContractFactory("MeetupTracker");
    const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
    await meetupTracker.deployed();

    const firstMeetupCreated: any = await meetupTracker.connect(deployer).createMeetup(title, city, startsDate, endsDate);

    const firstMeetupTx = await firstMeetupCreated.wait();

    const meetupAddress = firstMeetupTx.events[2].args[2];
    const meetupTrackerAddress = meetupTracker.address;

    return { meetupTracker, meetupAddress, meetupTrackerAddress, deployer, user1, user2, user3 };
  }

  it("reg", async function () {
    const { meetupAddress, deployer, user1 } = await loadFixture(deploy);

    const firstMeetup: Meetup = Meetup__factory.connect(meetupAddress, user1);

    const meetupTracker = firstMeetup.tracker();

    const amount = ethers.utils.parseEther("1");

    const initialBalance = await ethers.provider.getBalance(meetupTracker);

    const updatedBalance = await ethers.provider.getBalance(meetupTracker);
    console.log(updatedBalance);

    await expect(firstMeetup["reg(string)"]("Dima")).to.not.be.reverted;

    const tx = await firstMeetup.doDonate(0);
    await tx.wait();

    //await expect(updatedBalance).to.equal(initialBalance.add(100));

    await expect(firstMeetup.doDonate(0)).to.be.revertedWith("Donation can't be less than zero");

    // await expect(meetup.connect(user1).doDonate(100)).to.to.not.be.reverted;
  });
});
