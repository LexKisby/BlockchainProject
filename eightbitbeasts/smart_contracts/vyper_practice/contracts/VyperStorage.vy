stored_data: uint256


event Checked:
    name: address
    new_num: uint256

@external
def set(new_value : uint256):
    self.stored_data = new_value
    log Checked(msg.sender, new_value)

@external
@view
def get() -> uint256:
    return self.stored_data
