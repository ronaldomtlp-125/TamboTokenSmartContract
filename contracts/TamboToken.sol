// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importamos los contratos necesarios desde OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TamboToken is ERC20, Ownable, Pausable {
    uint256 public maxSupply; // Suministro máximo de tokens
    mapping(address => uint256) public stakedTokens; // Tokens en staking
    mapping(address => uint256) public stakingRewards; // Recompensas de staking

    // Constructor del token
    constructor(uint256 initialSupply, uint256 _maxSupply) ERC20("TamboToken", "TBT") Ownable(msg.sender) {
        maxSupply = _maxSupply * (10 ** decimals()); // Definimos el suministro máximo
        _mint(msg.sender, initialSupply * (10 ** decimals())); // El propietario recibe el suministro inicial
    }

    // Función para emitir tokens siempre que no se supere el suministro máximo
    function rewardTokens(address recipient, uint256 amount) external onlyOwner whenNotPaused {
        uint256 amountWithDecimals = amount * (10 ** decimals());
        require(totalSupply() + amountWithDecimals <= maxSupply, "No se pueden acuniar mas tokens, se excede el maximo.");
        _mint(recipient, amountWithDecimals); // Emitimos tokens sin superar el maxSupply
    }

    // Función para canjear tokens (quemarlos)
    function redeemTokens(uint256 amount) external whenNotPaused {
        _burn(msg.sender, amount * (10 ** decimals()));
    }

    // Función para transferir tokens entre usuarios
    function transferTokens(address recipient, uint256 amount) external whenNotPaused {
        transfer(recipient, amount * (10 ** decimals()));
    }

    // Función para pausar el contrato (solo el propietario puede pausar)
    function pause() external onlyOwner {
        _pause();
    }

    // Función para reanudar el contrato (solo el propietario puede reanudar)
    function unpause() external onlyOwner {
        _unpause();
    }

    // Función para hacer staking (bloquear tokens para recompensas)
    function stakeTokens(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount * (10 ** decimals()), "No tienes suficientes tokens para hacer staking.");
        _burn(msg.sender, amount * (10 ** decimals())); // Quemamos los tokens para hacer staking
        stakedTokens[msg.sender] += amount * (10 ** decimals()); // Actualizamos el balance de staking
    }

    // Función para reclamar recompensas por staking
    function claimStakingRewards() external whenNotPaused {
        uint256 rewards = calculateRewards(msg.sender);
        require(rewards > 0, "No tienes recompensas pendientes.");
        stakingRewards[msg.sender] = 0; // Reseteamos las recompensas
        _mint(msg.sender, rewards); // Emitimos las recompensas al usuario
    }

    // Función para calcular las recompensas basadas en el staking
    function calculateRewards(address staker) public view returns (uint256) {
        return stakedTokens[staker] / 10; // Ejemplo simple: 10% de los tokens en staking
    }

    // Eventos para monitorear actividades
    event TokensRewarded(address indexed recipient, uint256 amount);
    event TokensRedeemed(address indexed redeemer, uint256 amount);
    event TokensStaked(address indexed staker, uint256 amount);
    event RewardsClaimed(address indexed staker, uint256 amount);
}