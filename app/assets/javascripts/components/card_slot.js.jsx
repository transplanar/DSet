var CardSlot = React.createClass ({
  render: function() {
    var img = this.props.image_url;
    var url =  this.props.url;
    return (
      <div className="card_image">
        <a href={url}><img src={img} /></a>
      </div>
    );
  }
});
