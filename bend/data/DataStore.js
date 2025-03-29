// DataStore.js - Mock in-memory data store for MVP
class DataStore {
  constructor(storeName) {
    this.storeName = storeName;
    this.data = DataStore.stores[storeName] || [];
    DataStore.stores[storeName] = this.data;
  }

  // Save a new item
  async save(item) {
    // Make a copy to avoid reference issues
    const itemToSave = JSON.parse(JSON.stringify(item));
    
    // Ensure we have an ID
    if (!itemToSave.id) {
      itemToSave.id = Date.now().toString();
    }
    
    this.data.push(itemToSave);
    return itemToSave;
  }

  // Get all items
  async getAll() {
    return [...this.data]; // Return a copy
  }

  // Get item by ID
  async getById(id) {
    const item = this.data.find(item => item.id === id);
    return item ? JSON.parse(JSON.stringify(item)) : null;
  }

  // Update an existing item
  async update(id, updatedItem) {
    const index = this.data.findIndex(item => item.id === id);
    
    if (index === -1) {
      return null;
    }
    
    // Make a copy to avoid reference issues
    const itemToUpdate = JSON.parse(JSON.stringify(updatedItem));
    
    // Ensure ID remains the same
    itemToUpdate.id = id;
    
    this.data[index] = itemToUpdate;
    return itemToUpdate;
  }

  // Delete an item
  async delete(id) {
    const index = this.data.findIndex(item => item.id === id);
    
    if (index === -1) {
      return false;
    }
    
    this.data.splice(index, 1);
    return true;
  }

  // Clear all data
  async clear() {
    this.data = [];
    DataStore.stores[this.storeName] = this.data;
    return true;
  }
}

// Shared storage for all instances
DataStore.stores = {
  journalEntries: [],
  healthData: [],
  narratives: []
};

// Add some mock data for development
// Mock journal entries
DataStore.stores.journalEntries = [
  {
    id: '1',
    userId: 'user1',
    timestamp: new Date('2025-03-25T08:30:00').toISOString(),
    mood: 3,
    energy: 2,
    symptoms: [{name: 'Headache', severity: 6}],
    notes: 'Slept poorly last night. Busy day with back-to-back meetings.',
    tags: ['stress', 'poor_sleep']
  },
  {
    id: '2',
    userId: 'user1',
    timestamp: new Date('2025-03-26T09:15:00').toISOString(),
    mood: 3,
    energy: 3,
    symptoms: [],
    notes: 'Feeling better today. Made time for breakfast.',
    tags: []
  },
  {
    id: '3',
    userId: 'user1',
    timestamp: new Date('2025-03-27T08:45:00').toISOString(),
    mood: 4,
    energy: 4,
    symptoms: [],
    notes: 'Productive day. Took a walk during lunch break.',
    tags: ['good_day']
  },
  {
    id: '4',
    userId: 'user1',
    timestamp: new Date('2025-03-28T07:30:00').toISOString(),
    mood: 3,
    energy: 3,
    symptoms: [],
    notes: 'Normal day. Nothing special to report.',
    tags: []
  },
  {
    id: '5',
    userId: 'user1',
    timestamp: new Date('2025-03-29T08:00:00').toISOString(),
    mood: 2,
    energy: 2,
    symptoms: [{name: 'Headache', severity: 7}, {name: 'Fatigue', severity: 6}],
    notes: 'Skipped breakfast, worked through lunch. Headache started around 2pm.',
    tags: ['skipped_meals', 'headache']
  }
];

// Mock health data
DataStore.stores.healthData = [
  // Sleep data
  {
    id: '101',
    userId: 'user1',
    type: 'sleep',
    value: 5.5,
    unit: 'hours',
    timestamp: new Date('2025-03-25T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '102',
    userId: 'user1',
    type: 'sleep',
    value: 6.5,
    unit: 'hours',
    timestamp: new Date('2025-03-26T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '103',
    userId: 'user1',
    type: 'sleep',
    value: 7.2,
    unit: 'hours',
    timestamp: new Date('2025-03-27T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '104',
    userId: 'user1',
    type: 'sleep',
    value: 6.8,
    unit: 'hours',
    timestamp: new Date('2025-03-28T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '105',
    userId: 'user1',
    type: 'sleep',
    value: 6.1,
    unit: 'hours',
    timestamp: new Date('2025-03-29T00:00:00').toISOString(),
    source: 'apple_health'
  },
  
  // Steps data
  {
    id: '201',
    userId: 'user1',
    type: 'steps',
    value: 4200,
    unit: 'count',
    timestamp: new Date('2025-03-25T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '202',
    userId: 'user1',
    type: 'steps',
    value: 6500,
    unit: 'count',
    timestamp: new Date('2025-03-26T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '203',
    userId: 'user1',
    type: 'steps',
    value: 9100,
    unit: 'count',
    timestamp: new Date('2025-03-27T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '204',
    userId: 'user1',
    type: 'steps',
    value: 7200,
    unit: 'count',
    timestamp: new Date('2025-03-28T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '205',
    userId: 'user1',
    type: 'steps',
    value: 3800,
    unit: 'count',
    timestamp: new Date('2025-03-29T00:00:00').toISOString(),
    source: 'apple_health'
  },
  
  // Heart rate data
  {
    id: '301',
    userId: 'user1',
    type: 'heartRate',
    value: 72,
    unit: 'bpm',
    timestamp: new Date('2025-03-25T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '302',
    userId: 'user1',
    type: 'heartRate',
    value: 70,
    unit: 'bpm',
    timestamp: new Date('2025-03-26T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '303',
    userId: 'user1',
    type: 'heartRate',
    value: 68,
    unit: 'bpm',
    timestamp: new Date('2025-03-27T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '304',
    userId: 'user1',
    type: 'heartRate',
    value: 69,
    unit: 'bpm',
    timestamp: new Date('2025-03-28T00:00:00').toISOString(),
    source: 'apple_health'
  },
  {
    id: '305',
    userId: 'user1',
    type: 'heartRate',
    value: 74,
    unit: 'bpm',
    timestamp: new Date('2025-03-29T00:00:00').toISOString(),
    source: 'apple_health'
  }
];

module.exports = DataStore;
