# @version >=0.2.4 <3.0.0


stored_data: uint256
ruby: uint256
essence: uint256


event CheckedSt:
    name: address
    new_num: uint256

event CheckedRuby:
    name: address
    new_num: uint256

event CheckedEss:
    name: address
    new_num: uint256

@external
def set(new_value : uint256):
    self.stored_data = new_value
    log CheckedSt(msg.sender, new_value)

@external
@view
def get() -> uint256:
    return self.stored_data





@external
@view
def getRubyBalance() -> uint256:
    return self.ruby

@external
def setRubyBalance(new_value: uint256):
    self.ruby = new_value
    log CheckedRuby(msg.sender, new_value)
    
@external
@view
def getEssenceBalance() -> uint256:
    return self.essence

@external
def setEssenceBalance(new_value: uint256):
    self.essence = new_value
    log CheckedEss(msg.sender, new_value)