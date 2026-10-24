export const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3'

export const SCIENTIFIC_FUND_ABI = [
  'function contribute() payable',
  'function totalRaised() view returns (uint256)',
  'function milestoneCount() view returns (uint256)',
  'function createMilestone(string memory title, string memory ipfsHash, uint256 amount) external',
  'function voteMilestone(uint256 milestoneId, bool support) external',
  'function releaseMilestone(uint256 milestoneId) external',
  'function owner() view returns (address)',
  'function isMilestoneReleased(uint256 milestoneId) view returns (bool)',
  'event Contribution(address indexed donor, uint256 amount, uint256 totalRaised_)',
]
