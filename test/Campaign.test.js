const Campaign = artifacts.require('./Campaign.sol');
const utils = require('./utils');

contract('Campaign', function (accounts) {

    const [
        main,
        participant1,
        participant2,
        participant3,
        participant4,
        participant5,
        participant6,
        participant7,
        participant8,
        participant9
    ] = accounts;

    const hardCap = utils.toWei(10);
    const minInvest = utils.toWei(0.5);

    let campaign;

    beforeEach(async () => {
        const nextYearDate = getNextYearDate();
        const year = nextYearDate.year;
        const month = nextYearDate.month;
        const day = nextYearDate.day;
        campaign = await Campaign.new(hardCap, minInvest, year, month, day);
    });

    it('Participant should be able to invest', async () => {
        const trx = await participate(participant1, 1);
        const newParticipantEvent = trx.logs[0];
        console.log(newParticipantEvent);
    });


    function getNextYearDate() {
        const date = new Date();
        const [year, month, day] = date.toLocaleDateString().split('-');
        return {year: parseInt(year) + 1, month: parseInt(month), day: parseInt(day)};
    }

    async function participate(address, etherVal) {
        return await campaign.participate({from: address, value: utils.toWei(etherVal)});
    }

    async function forceFinish() {
        return await campaign.finishCampaign({from: main});
    }

    async function participantsCount() {
        return (await campaign.participantsCount({from: main})).toNumber();
    }

    async function participantInvested(address) {
        return (await campaign.participantInvested(address, {from: main})).toNumber();
    }

});


