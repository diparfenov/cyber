import { loadFixture, ethers, SignerWithAddress, expect, BigNumberish } from "../setup";
import type { Meetup, MeetupTracker } from "../typechain-types";

describe("Meetup", function () {
  let title: string = "The Scaling Meetup";
  let city: string = "Tbilisi";
  let startsDate: BigNumberish = ethers.BigNumber.from(1685037600); //25.05.2023-18:00
  let endsDate: BigNumberish = ethers.BigNumber.from(1685048400); //25.05.2023-21:00
  let index0: BigNumberish = ethers.BigNumber.from(0);

  let newTitle: string = "The Scaling Meetup V2";

  async function deploy() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MeetupFactory = await ethers.getContractFactory("Meetup");
    const meetup: Meetup = await MeetupFactory.deploy();
    await MeetupFactory.deployed();

    return { meetup, deployer, user1, user2, user3 };
  }

  it("meetup", async function () {
    const { meetup, deployer, user1 } = await loadFixture(deploy);
    console.log(meetup);
  });
});
