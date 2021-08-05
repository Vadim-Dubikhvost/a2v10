
const template = {
    
    commands: {
        writeId
    }
  
};

module.exports = template;
function writeId(result) {
    this.$ctrl.$invoke('writeId', {Name: this.MemberName.Name, Id: this.Event.Id})
}