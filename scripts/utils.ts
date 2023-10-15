import { network } from "hardhat";

export async function mineBlocks(count: number) {
  for (let i = 0; i < count; i++) {
    network.provider.request({
      method: "evm_mine",
      params: [],
    });
  }
}

export async function timeTravel(amount: number) {
  await network.provider.send("evm_increaseTime", [amount]);
}
