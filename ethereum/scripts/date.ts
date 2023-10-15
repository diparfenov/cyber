import { BigNumber, ethers } from "ethers";

async function main() {
    // Пример строки с датой
    const dateString: string = "2023-05-01T12:00:00Z";

    // Преобразование строки в объект Date
    const date: Date = new Date(dateString);

    // Получение timestamp из объекта Date
    const timestamp: number = Math.floor(date.getTime() / 1000);

    // Преобразование timestamp в BigNumber
    const bigNumber: BigNumber = ethers.BigNumber.from(timestamp);

    console.log(bigNumber.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
