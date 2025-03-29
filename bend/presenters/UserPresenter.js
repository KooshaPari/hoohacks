const { UserController } = require('../controllers');

/**
 * UserPresenter - Handles presenting user data for the API
 */
class UserPresenter {
  /**
   * Register a new user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async registerUser(req, res) {
    try {
      const userData = req.body;
      
      if (!userData.name || !userData.email || !userData.password) {
        return res.status(400).json({
          success: false,
          error: 'Name, email and password are required'
        });
      }
      
      const result = await UserController.createUser(userData);
      
      return res.status(201).json({
        success: true,
        data: result.user
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * Login a user
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async loginUser(req, res) {
    try {
      const { email, password } = req.body;
      
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          error: 'Email and password are required'
        });
      }
      
      const user = await UserController.authenticateUser(email, password);
      
      return res.status(200).json({
        success: true,
        data: {
          user,
          token: 'mock-jwt-token' // In a real implementation, this would be a JWT
        }
      });
    } catch (error) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }
  }

  /**
   * Get a user's profile
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getUserProfile(req, res) {
    try {
      const { userId } = req.params;
      
      const user = await UserController.getUserById(userId);
      
      return res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
  }

  /**
   * Update a user's profile
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async updateUserProfile(req, res) {
    try {
      const { userId } = req.params;
      const updateData = req.body;
      
      const user = await UserController.updateUser(userId, updateData);
      
      return res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = new UserPresenter();
