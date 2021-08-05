const template = {
  
    delegates: {
        uploadAttachment
    },
    commands: {
      
    }

};

module.exports = template;



function uploadAttachment(result) {
    console.dir(this);
    console.dir(result);
    if (this.Members.$selected) {
        this.Members.$selected.ImageId = result[0].Id;
        this.Members.$selected.Image.Id = result[0].Id;
        this.Members.$selected.Image.Token = result[0].Token;
        this.$ctrl.$invoke('writeImageId', { Id: this.Members.$selected.Id, ImageId: this.Members.$selected.ImageId});
    }
    //let coll = this.Members.Image;
    //for (let i = 0; i < result.length; i++)
    //    coll.$append(result[i]);
}

