const template = {
    validators: {
        "Member.Name":
            [{ valid: isNameValid, msg: 'Empty field' }],
        "Member.BM":
            [{ valid: isBmValid, msg: 'Format is 555555' }],
        "Member.Def":
            [{ valid: isDefValid, msg: 'Format is 11111' }],
        "Member.Res":
            [{ valid: isResValid, msg: 'Format is 11111' }],
        "Member.Res_crit":
            [{ valid: isRes_critValid, msg: 'Limit is exceeded,enter in %' }],
        "Member.Res_rage":
            [{ valid: isRes_rageValid, msg: 'Limit is exceeded(max 40),enter in %' }]
    }

};

module.exports = template;


function isNameValid(member) {
    console.dir(member);
    return member.Name.length > 2;
}

function isBmValid(member) {
    return member.BM <= 999999;
}

function isDefValid(member) {
    return member.Def <= 30000;
}

function isResValid(member) {
    return member.Res <= 30000;
}

function isRes_critValid(member) {
    return member.Res_crit <= 99;
}

function isRes_rageValid(member) {
    return member.Res_rage <= 99;
}

