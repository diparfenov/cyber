import { loadFixture, ethers, SignerWithAddress, expect, BigNumberish } from "../setup";
import { Meetup__factory, type Meetup, type MeetupTracker, MeetupTracker__factory } from "../typechain-types";
import { mineBlocks, timeTravel } from "../scripts/utils";

describe("Meetup", function () {
  let title: string = "The First Meetup";
  let city: string = "Oslo";
  let startsDate: BigNumberish = ethers.BigNumber.from(1696731072); //11 Jul 2023 11:48:46 GMT
  let endsDate: BigNumberish = ethers.BigNumber.from(1690067079); //11 Jul 2023 21:48:46 GMT

  async function deploy() {
    const [deployer, user1, user2, user3, user4, user5, user6] = await ethers.getSigners();

    const MeetupTrackerFactory = await ethers.getContractFactory("MeetupTracker");
    const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
    await meetupTracker.deployed();

    const firstMeetupCreated: any = await meetupTracker.connect(deployer).createMeetup(title, city, startsDate, endsDate);

    const firstMeetupTx = await firstMeetupCreated.wait();

    const meetupAddress = firstMeetupTx.events[2].args[2];
    const meetupTrackerAddress = meetupTracker.address;

    return { meetupTracker, meetupAddress, meetupTrackerAddress, deployer, user1, user2, user3, user4, user5, user6 };
  }

  it("doDonate and change MeetupTracker's balance", async function () {
    const { meetupAddress, meetupTrackerAddress, user1 } = await loadFixture(deploy);

    const firstMeetup: Meetup = Meetup__factory.connect(meetupAddress, user1);
    const meetupTracker: MeetupTracker = MeetupTracker__factory.connect(meetupTrackerAddress, user1);

    const amount1 = ethers.utils.parseEther("1");
    const amount2 = ethers.utils.parseEther("2");

    const initialBalance = await ethers.provider.getBalance(meetupTrackerAddress);

    await firstMeetup.doDonate({ value: amount1 });

    let tx = {
      to: meetupAddress,
      value: amount1,
    };

    let sendMoneyTx = await user1.sendTransaction(tx);
    await sendMoneyTx.wait();

    const updatedBalance1 = await ethers.provider.getBalance(meetupTrackerAddress);

    await expect(updatedBalance1).to.eq(initialBalance.add(amount2));

    await expect(firstMeetup.doDonate({ value: amount1 })).to.not.be.reverted;
    await expect(firstMeetup.doDonate({ value: 0 })).to.be.revertedWith("Donation can't be less than zero");

    const updatedBalance2 = await ethers.provider.getBalance(meetupTrackerAddress);
    const valueInMapping = await meetupTracker.viewDonate(0, user1.address);

    await expect(valueInMapping).to.eq(updatedBalance2);
  });
  //wwr

  ///qd
  it("reg", async function () {
    const { meetupAddress, deployer, user1, user2, user3, user4 } = await loadFixture(deploy);

    await expect(Meetup__factory.connect(meetupAddress, user1)["reg(string)"]("Dima")).to.not.be.reverted;
    await expect(Meetup__factory.connect(meetupAddress, user1)["reg(string)"]("Dima")).to.be.revertedWith("You're already registred!");

    await expect(Meetup__factory.connect(meetupAddress, user2)["reg(string,string,string)"]("Dasha", "WebMedia", "PM")).to.not.be.reverted;
    await expect(Meetup__factory.connect(meetupAddress, user2)["reg(string,string,string)"]("Dasha", "WebMedia", "PM")).to.be.revertedWith("You're already registred!");

    //отматываем время - мероприятие уже началось, но еще не закончилось
    await timeTravel(1000000);
    await expect(Meetup__factory.connect(meetupAddress, user3)["reg(string)"]("Dima")).to.be.revertedWith("Registration has already ended");
    await expect(Meetup__factory.connect(meetupAddress, user3)["reg(string,string,string)"]("Dasha", "WebMedia", "PM")).to.be.revertedWith("Registration has already ended");

    //отматываем время - мероприятие уже закончилось
    await timeTravel(1000000000);
    await Meetup__factory.connect(meetupAddress, deployer).closeMeetup();

    await expect(Meetup__factory.connect(meetupAddress, user4)["reg(string)"]("Dima")).to.be.revertedWith("Meetup has already ended");
    await expect(Meetup__factory.connect(meetupAddress, user4)["reg(string,string,string)"]("Dasha", "WebMedia", "PM")).to.be.revertedWith("Meetup has already ended");
  });

  it("regWithCompany", async function () {
    const { meetupAddress, deployer, user1, user2, user3 } = await loadFixture(deploy);

    await expect(Meetup__factory.connect(meetupAddress, user1).regWithCompany("Alex", "HR")).to.not.be.reverted;
    await expect(Meetup__factory.connect(meetupAddress, user1).regWithCompany("Alex", "HR")).to.be.revertedWith("You're already registred!");

    //отматываем время - мероприятие уже началось, но еще не закончилось
    await timeTravel(1000000);
    await expect(Meetup__factory.connect(meetupAddress, user2).regWithCompany("Alex", "HR")).to.be.revertedWith("Registration has already ended");

    //отматываем время - мероприятие уже закончилось
    await timeTravel(1000000000);
    await Meetup__factory.connect(meetupAddress, deployer).closeMeetup();

    await expect(Meetup__factory.connect(meetupAddress, user3).regWithCompany("Alex", "HR")).to.be.revertedWith("Meetup has already ended");
  });

  it("regWithRole", async function () {
    const { meetupAddress, deployer, user1, user2, user3 } = await loadFixture(deploy);

    await expect(Meetup__factory.connect(meetupAddress, user1).regWithRole("Pasha", "Dev")).to.not.be.reverted;
    await expect(Meetup__factory.connect(meetupAddress, user1).regWithRole("Pasha", "Dev")).to.be.revertedWith("You're already registred!");

    //отматываем время - мероприятие уже началось, но еще не закончилось
    await timeTravel(1000000);
    await expect(Meetup__factory.connect(meetupAddress, user2).regWithRole("Pasha", "Dev")).to.be.revertedWith("Registration has already ended");

    //отматываем время - мероприятие уже закончилось
    await timeTravel(1000000000);
    await Meetup__factory.connect(meetupAddress, deployer).closeMeetup();

    await expect(Meetup__factory.connect(meetupAddress, user3).regWithRole("Pasha", "Dev")).to.be.revertedWith("Meetup has already ended");
  });

  it("closeMeetup", async function () {
    const { meetupAddress, deployer, user1 } = await loadFixture(deploy);

    await expect(Meetup__factory.connect(meetupAddress, user1).closeMeetup()).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(Meetup__factory.connect(meetupAddress, deployer).closeMeetup()).to.be.revertedWith("Meetup is not over yet!");

    //отматываем время - мероприятие уже закончилось
    await timeTravel(1000000000);
    await expect(Meetup__factory.connect(meetupAddress, deployer).closeMeetup()).to.not.be.reverted;
    await expect(Meetup__factory.connect(meetupAddress, deployer).closeMeetup()).to.be.revertedWith("Meetup already closed!");
  });

  it("changeTitle", async function () {
    const { meetupAddress, meetupTrackerAddress, deployer, user1 } = await loadFixture(deploy);

    const meetupTracker: MeetupTracker = MeetupTracker__factory.connect(meetupTrackerAddress, deployer);
    const newTitle: string = "NewTitle";

    await expect(Meetup__factory.connect(meetupAddress, user1).changeTitle(newTitle)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(Meetup__factory.connect(meetupAddress, deployer).changeTitle(newTitle)).to.not.be.reverted;

    const newTitleInMapping = (await meetupTracker.meetups(0)).title;

    await expect(newTitleInMapping).to.eq(newTitle);
  });

  it("changeCity", async function () {
    const { meetupAddress, deployer, user1 } = await loadFixture(deploy);

    const newCity: string = "NewCity";

    await expect(Meetup__factory.connect(meetupAddress, user1).changeCity(newCity)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(Meetup__factory.connect(meetupAddress, deployer).changeCity(newCity)).to.not.be.reverted;

    const changedCity = await Meetup__factory.connect(meetupAddress, user1).city();

    await expect(changedCity).to.eq(newCity);
  });

  it("changeDate", async function () {
    const { meetupAddress, deployer, user1 } = await loadFixture(deploy);

    const newStartsDate: string = "10";
    const newEndsDate: string = "11";

    await expect(Meetup__factory.connect(meetupAddress, user1).changeDate(newStartsDate, newEndsDate)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(Meetup__factory.connect(meetupAddress, deployer).changeDate(newStartsDate, newEndsDate)).to.not.be.reverted;

    const changedStartsDate = await Meetup__factory.connect(meetupAddress, user1).startsDate();
    const changedEndssDate = await Meetup__factory.connect(meetupAddress, user1).endsDate();

    await expect(changedStartsDate).to.eq(newStartsDate);
    await expect(changedEndssDate).to.eq(newEndsDate);
  });

  it("verify", async function () {
    const { meetupAddress, deployer, user1 } = await loadFixture(deploy);

    await expect(Meetup__factory.connect(meetupAddress, user1).changeCity(newCity)).to.be.revertedWith("Ownable: caller is not the owner");
    await expect(Meetup__factory.connect(meetupAddress, deployer).changeCity(newCity)).to.not.be.reverted;

    const changedCity = await Meetup__factory.connect(meetupAddress, user1).city();

    await expect(changedCity).to.eq();
  });
});
