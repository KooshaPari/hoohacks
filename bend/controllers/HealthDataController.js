const HealthData = require('../models/healthDataModel');

exports.createHealthData = async (req, res, next) => {
  try {
    // Add user id to request body
    req.body.user = req.user.id;
    
    const newHealthData = await HealthData.create(req.body);
    
    res.status(201).json({
      status: 'success',
      data: {
        healthData: newHealthData
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getAllHealthData = async (req, res, next) => {
  try {
    // Build query - only get data for the logged in user
    let query = HealthData.find({ user: req.user.id });
    
    // Filter by data type
    if (req.query.dataType) {
      query = query.find({ dataType: req.query.dataType });
    }
    
    // Filter by date range
    if (req.query.from && req.query.to) {
      query = query.find({
        date: {
          $gte: new Date(req.query.from),
          $lte: new Date(req.query.to)
        }
      });
    }
    
    // Sorting
    if (req.query.sort) {
      query = query.sort(req.query.sort);
    } else {
      query = query.sort('-date'); // Default sort by date, newest first
    }
    
    // Pagination
    const page = req.query.page * 1 || 1;
    const limit = req.query.limit * 1 || 100;
    const skip = (page - 1) * limit;
    
    query = query.skip(skip).limit(limit);
    
    // Execute query
    const healthData = await query;
    
    res.status(200).json({
      status: 'success',
      results: healthData.length,
      data: {
        healthData
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getHealthData = async (req, res, next) => {
  try {
    const healthData = await HealthData.findOne({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!healthData) {
      return res.status(404).json({
        status: 'fail',
        message: 'No health data found with that ID'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: {
        healthData
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.updateHealthData = async (req, res, next) => {
  try {
    const healthData = await HealthData.findOneAndUpdate(
      {
        _id: req.params.id,
        user: req.user.id
      },
      req.body,
      {
        new: true,
        runValidators: true
      }
    );
    
    if (!healthData) {
      return res.status(404).json({
        status: 'fail',
        message: 'No health data found with that ID'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: {
        healthData
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.deleteHealthData = async (req, res, next) => {
  try {
    const healthData = await HealthData.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!healthData) {
      return res.status(404).json({
        status: 'fail',
        message: 'No health data found with that ID'
      });
    }
    
    res.status(204).json({
      status: 'success',
      data: null
    });
  } catch (err) {
    next(err);
  }
};

exports.getSleepStats = async (req, res, next) => {
  try {
    const stats = await HealthData.aggregate([
      {
        $match: { 
          user: req.user._id,
          dataType: 'sleep'
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
          avgDuration: { $avg: '$values.duration' },
          avgDeepSleep: { $avg: '$values.deepSleepMinutes' },
          avgRemSleep: { $avg: '$values.remSleepMinutes' },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { _id: -1 }
      },
      {
        $limit: 30 // Last 30 days
      }
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        stats
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getActivityStats = async (req, res, next) => {
  try {
    const stats = await HealthData.aggregate([
      {
        $match: { 
          user: req.user._id,
          dataType: 'activity'
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
          avgSteps: { $avg: '$values.steps' },
          avgCalories: { $avg: '$values.activeCalories' },
          avgExerciseMinutes: { $avg: '$values.exerciseMinutes' },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { _id: -1 }
      },
      {
        $limit: 30 // Last 30 days
      }
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        stats
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getHeartRateStats = async (req, res, next) => {
  try {
    const stats = await HealthData.aggregate([
      {
        $match: { 
          user: req.user._id,
          dataType: 'heartRate'
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
          avgRestingHR: { $avg: '$values.restingHeartRate' },
          avgHRV: { $avg: '$values.heartRateVariability' },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { _id: -1 }
      },
      {
        $limit: 30 // Last 30 days
      }
    ]);
    
    res.status(200).json({
      status: 'success',
      data: {
        stats
      }
    });
  } catch (err) {
    next(err);
  }
};
