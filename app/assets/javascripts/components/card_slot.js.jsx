var styles = {
  display: 'inline',
  marginBottom: 20
}

var CardSlot = React.createClass ({
  render: function() {
    var img = this.props.image_url;
    var url =  this.props.url;
    return (
      <a href={url}><img style={styles} src={img} /></a>
    );
  }
});
