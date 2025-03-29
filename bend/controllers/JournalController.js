const JournalEntry = require('../models/journalEntryModel');

exports.createEntry = async (req, res, next) => {
  try {
    // Add user id to request body
    req.body.user = req.user.id;
    
    const newEntry = await JournalEntry.create(req.body);
    
    res.status(201).json({
      status: 'success',
      data: {
        journalEntry: newEntry
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getAllEntries = async (req, res, next) => {
  try {
    // Build query - only get entries for the logged in user
    let query = JournalEntry.find({ user: req.user.id });
    
    // Filtering
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
    const entries = await query;
    
    res.status(200).json({
      status: 'success',
      results: entries.length,
      data: {
        journalEntries: entries
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getEntry = async (req, res, next) => {
  try {
    const entry = await JournalEntry.findOne({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!entry) {
      return res.status(404).json({
        status: 'fail',
        message: 'No journal entry found with that ID'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: {
        journalEntry: entry
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.updateEntry = async (req, res, next) => {
  try {
    const entry = await JournalEntry.findOneAndUpdate(
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
    
    if (!entry) {
      return res.status(404).json({
        status: 'fail',
        message: 'No journal entry found with that ID'
      });
    }
    
    res.status(200).json({
      status: 'success',
      data: {
        journalEntry: entry
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.deleteEntry = async (req, res, next) => {
  try {
    const entry = await JournalEntry.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!entry) {
      return res.status(404).json({
        status: 'fail',
        message: 'No journal entry found with that ID'
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

exports.getStats = async (req, res, next) => {
  try {
    const stats = await JournalEntry.aggregate([
      {
        $match: { user: req.user._id }
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
          avgMood: { $avg: '$mood' },
          avgEnergy: { $avg: '$energy' },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { _id: -1 }
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
