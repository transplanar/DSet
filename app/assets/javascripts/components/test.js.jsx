var TestComponent = React.createClass ({
  render() {
    var test = this.props.test_prop;
    return (
      <div>
        <h1>Success!</h1>
        {test}
      </div>
    );
  }
});
