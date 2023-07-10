// import { loadFixture, ethers, SignerWithAddress, expect, BigNumberish } from "../setup";
// import type { Meetup, MeetupTracker } from "../typechain-types";

// describe("MeetupTracker", function () {
//   let title: string = "The Scaling Meetup";
//   let city: string = "Tbilisi";
//   let startsDate: BigNumberish = ethers.BigNumber.from(1689070996); //06 Jul 2023 11:48:46 GMT
//   let endsDate: BigNumberish = ethers.BigNumber.from(1689103396); // Jul 2023 21:48:46 GMT
//   let index0: BigNumberish = ethers.BigNumber.from(0);

//   let newTitle: string = "The Scaling Meetup V2";

//   async function deploy() {
//     const [deployer, user1, user2, user3] = await ethers.getSigners();

//     const MeetupTrackerFactory = await ethers.getContractFactory("MeetupTracker");
//     const meetupTracker: MeetupTracker = await MeetupTrackerFactory.deploy();
//     await meetupTracker.deployed();

//     const firstMeetupCreated: any = await meetupTracker.connect(deployer).createMeetup(title, city, startsDate, endsDate);
//     const firstMeetupTx = await firstMeetupCreated.wait();

//     return { meetupTracker, firstMeetupCreated, firstMeetupTx, deployer, user1, user2, user3 };
//   }

//   it("createdMeetup", async function () {
//     const { meetupTracker, firstMeetupTx, user1 } = await loadFixture(deploy);

//     const block = await ethers.provider.getBlock(firstMeetupTx.blockHash);
//     const blockTime = block.timestamp;

//     const firstMeetupInArray = await meetupTracker.meetups(index0);

//     await expect(firstMeetupInArray.meetup).to.eq(firstMeetupTx.events[2].args[2]);
//     await expect(firstMeetupInArray.title).to.eq(title);
//     await expect(firstMeetupInArray.index).to.eq(index0);
//     await expect(firstMeetupInArray.isActive).to.eq(true);
//     await expect(firstMeetupInArray.timeCreated).to.eq(blockTime);

//     await expect(meetupTracker.connect(user1).createMeetup(title, city, startsDate, endsDate)).to.be.revertedWith("Ownable: caller is not the owner");

//     await expect(await meetupTracker.connect(user1).getMeetupByIndex(index0)).to.not.be.reverted;
//     await expect(await meetupTracker.connect(user1).getMeetups()).to.not.be.reverted;
//   });

//   it("changeMeetupTitle", async function () {
//     const { meetupTracker, deployer, user1 } = await loadFixture(deploy);

//     await expect(meetupTracker.connect(user1).changeMeetupTitle(index0, newTitle, user1.address)).to.be.revertedWith("You are not an owner!");

//     await expect(meetupTracker.connect(deployer).changeMeetupTitle(index0, newTitle, deployer.address)).to.not.be.reverted;

//     expect((await meetupTracker.meetups(index0)).title).to.eq(newTitle);
//   });

//   it("closeMeetupByIndex", async function () {
//     const { meetupTracker, deployer, user1 } = await loadFixture(deploy);

//     await expect(meetupTracker.connect(user1).closeMeetupByIndex(index0, user1.address)).to.be.revertedWith("You are not an owner!");

//     await expect(meetupTracker.connect(deployer).closeMeetupByIndex(index0, deployer.address)).to.not.be.reverted;

//     await expect((await meetupTracker.meetups(index0)).isActive).to.eq(false);

//     await expect(meetupTracker.connect(deployer).closeMeetupByIndex(index0, deployer.address)).to.be.revertedWith("Meetup already closed!");
//   });

//   it("donate, donateGlobal and withdraw", async function () {
//     const { meetupTracker, deployer, user1, user2 } = await loadFixture(deploy);

//     const firstValue = 100000;
//     const firstTx = await meetupTracker.connect(user1).donateGlobal({ value: firstValue });
//     await firstTx.wait();

//     const secondValue = 50000;
//     const secondTx = await meetupTracker.connect(user2).donate(index0, user2.address, { value: secondValue });
//     await secondTx.wait();

//     await expect(await meetupTracker.donatesGlobal(user1.address)).to.eq(firstValue);
//     await expect(await meetupTracker.donatesByAddress(index0, user2.address)).to.eq(secondValue);
//     await expect(await meetupTracker.viewDonate(index0, user2.address)).to.eq(secondValue);

//     await expect(meetupTracker.connect(user1).withdraw(1000)).to.be.revertedWith("Ownable: caller is not the owner");
//     await expect(meetupTracker.connect(deployer).withdraw(200000)).to.be.revertedWith("Insufficient balance");
//     await expect(meetupTracker.connect(deployer).withdraw(100000)).to.not.be.reverted;

//     await expect(meetupTracker.connect(user2).donate(index0, user2.address, { value: 100000 })).to.not.be.reverted;
//     await expect(meetupTracker.connect(user2).donate(index0, user2.address, { value: 0 })).to.be.revertedWith("Donation can't be less than zero");
//     await expect(meetupTracker.connect(user2).donate(4, user2.address, { value: 100000 })).to.be.revertedWith("Meetup not created");

//     await expect(meetupTracker.connect(user1).donateGlobal({ value: 100000 })).to.not.be.reverted;
//     await expect(meetupTracker.connect(user1).donateGlobal({ value: 0 })).to.be.revertedWith("Donation can't be less than zero");
//   });

//   it("should receive and update contract balance", async () => {
//     const { meetupTracker, deployer, user1 } = await loadFixture(deploy);

//     // Получение баланса контракта до вызова функции receive
//     const initialBalance = await ethers.provider.getBalance(meetupTracker.address);

//     const amount = ethers.utils.parseEther("1");

//     let tx = {
//       to: meetupTracker.address,
//       value: amount,
//     };

//     let sendMoneyTx = await user1.sendTransaction(tx);
//     await sendMoneyTx.wait();

//     // Получение обновленного баланса контракта после вызова функции receive
//     const updatedBalance = await ethers.provider.getBalance(meetupTracker.address);

//     // Проверка, что баланс контракта увеличился на amount
//     expect(updatedBalance).to.equal(initialBalance.add(amount));
//   });
// });
