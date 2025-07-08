const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Emotion = require('../models/Emotion');
const Notification = require('../models/Notification');

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/chatfun', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

// Initialize database with sample data
const initializeDB = async () => {
  try {
    // Clear existing data
    await User.deleteMany({});
    await Chat.deleteMany({});
    await Message.deleteMany({});
    await Emotion.deleteMany({});
    await Notification.deleteMany({});
    
    console.log('Cleared existing data');

    // Create sample users
    const users = [
      {
        name: 'Alice Johnson',
        email: 'alice@example.com',
        password: await bcrypt.hash('password123', 10),
        bio: 'Love creating digital art and chatting with friends!',
        isVerified: true,
        avatar: 'https://picsum.photos/200/200?random=1'
      },
      {
        name: 'Bob Smith',
        email: 'bob@example.com',
        password: await bcrypt.hash('password123', 10),
        bio: 'Photography enthusiast and tech lover',
        isVerified: true,
        avatar: 'https://picsum.photos/200/200?random=2'
      },
      {
        name: 'Charlie Brown',
        email: 'charlie@example.com',
        password: await bcrypt.hash('password123', 10),
        bio: 'Always excited about new adventures!',
        isVerified: true,
        avatar: 'https://picsum.photos/200/200?random=3'
      },
      {
        name: 'Diana Prince',
        email: 'diana@example.com',
        password: await bcrypt.hash('password123', 10),
        bio: 'Artist and dreamer ✨',
        isVerified: true,
        avatar: 'https://picsum.photos/200/200?random=4'
      },
      {
        name: 'Demo User',
        email: 'demo@chatfun.com',
        password: await bcrypt.hash('demo123', 10),
        bio: 'Demo user for testing the application',
        isVerified: true,
        avatar: 'https://picsum.photos/200/200?random=5'
      }
    ];

    const createdUsers = await User.insertMany(users);
    console.log(`Created ${createdUsers.length} users`);

    // Create friendships between users
    const [alice, bob, charlie, diana, demo] = createdUsers;
    
    // Make Alice friends with Bob and Charlie
    alice.friends.push(
      { user: bob._id, addedAt: new Date() },
      { user: charlie._id, addedAt: new Date() }
    );
    bob.friends.push(
      { user: alice._id, addedAt: new Date() },
      { user: diana._id, addedAt: new Date() }
    );
    charlie.friends.push(
      { user: alice._id, addedAt: new Date() },
      { user: diana._id, addedAt: new Date() }
    );
    diana.friends.push(
      { user: bob._id, addedAt: new Date() },
      { user: charlie._id, addedAt: new Date() }
    );
    demo.friends.push(
      { user: alice._id, addedAt: new Date() },
      { user: bob._id, addedAt: new Date() }
    );

    // Add friend requests
    alice.friendRequests.received.push({
      user: demo._id,
      receivedAt: new Date()
    });
    demo.friendRequests.sent.push({
      user: alice._id,
      sentAt: new Date()
    });

    await Promise.all([
      alice.save(),
      bob.save(),
      charlie.save(),
      diana.save(),
      demo.save()
    ]);

    // Create sample chats
    const chats = [
      {
        participants: [alice._id, bob._id],
        type: 'private',
        lastActivity: new Date()
      },
      {
        participants: [alice._id, charlie._id],
        type: 'private',
        lastActivity: new Date()
      },
      {
        participants: [bob._id, diana._id],
        type: 'private',
        lastActivity: new Date()
      },
      {
        participants: [alice._id, bob._id, charlie._id, diana._id],
        type: 'group',
        name: 'Art Lovers Group',
        description: 'A group for sharing art and creativity',
        admin: alice._id,
        lastActivity: new Date()
      }
    ];

    const createdChats = await Chat.insertMany(chats);
    console.log(`Created ${createdChats.length} chats`);

    // Create sample messages
    const messages = [
      {
        chat: createdChats[0]._id,
        sender: alice._id,
        content: { text: 'Hey Bob! How are you doing?' },
        type: 'text'
      },
      {
        chat: createdChats[0]._id,
        sender: bob._id,
        content: { text: 'Hi Alice! I\'m doing great, thanks for asking!' },
        type: 'text'
      },
      {
        chat: createdChats[1]._id,
        sender: charlie._id,
        content: { text: 'Alice, did you see the new Studio Ghibli movie?' },
        type: 'text'
      },
      {
        chat: createdChats[3]._id,
        sender: alice._id,
        content: { text: 'Welcome to our art lovers group! 🎨' },
        type: 'text'
      }
    ];

    const createdMessages = await Message.insertMany(messages);
    console.log(`Created ${createdMessages.length} messages`);

    // Update chats with last messages
    await Chat.findByIdAndUpdate(createdChats[0]._id, {
      lastMessage: createdMessages[1]._id,
      lastActivity: new Date()
    });
    await Chat.findByIdAndUpdate(createdChats[1]._id, {
      lastMessage: createdMessages[2]._id,
      lastActivity: new Date()
    });
    await Chat.findByIdAndUpdate(createdChats[3]._id, {
      lastMessage: createdMessages[3]._id,
      lastActivity: new Date()
    });

    // Create sample emotions
    const emotions = [
      {
        user: alice._id,
        originalImage: {
          url: 'https://picsum.photos/512/512?random=emotion1',
          filename: 'selfie1.jpg',
          size: 1024000,
          mimeType: 'image/jpeg'
        },
        detectedEmotion: {
          primary: 'happy',
          confidence: 0.85,
          allEmotions: [
            { emotion: 'happy', confidence: 0.85 },
            { emotion: 'excited', confidence: 0.12 },
            { emotion: 'neutral', confidence: 0.03 }
          ]
        },
        ghibliArt: {
          url: 'https://picsum.photos/512/512?random=ghibli1',
          style: 'ghibli',
          prompt: 'A joyful, bright Studio Ghibli character with a warm smile',
          generationTime: 3.2
        },
        metadata: {
          faceDetected: true,
          faceCount: 1,
          imageQuality: 'high',
          processingTime: 4.5
        }
      },
      {
        user: bob._id,
        originalImage: {
          url: 'https://picsum.photos/512/512?random=emotion2',
          filename: 'selfie2.jpg',
          size: 987000,
          mimeType: 'image/jpeg'
        },
        detectedEmotion: {
          primary: 'excited',
          confidence: 0.78,
          allEmotions: [
            { emotion: 'excited', confidence: 0.78 },
            { emotion: 'happy', confidence: 0.15 },
            { emotion: 'surprised', confidence: 0.07 }
          ]
        },
        ghibliArt: {
          url: 'https://picsum.photos/512/512?random=ghibli2',
          style: 'ghibli',
          prompt: 'An energetic Studio Ghibli character with sparkling eyes',
          generationTime: 2.8
        },
        metadata: {
          faceDetected: true,
          faceCount: 1,
          imageQuality: 'high',
          processingTime: 3.2
        }
      }
    ];

    const createdEmotions = await Emotion.insertMany(emotions);
    console.log(`Created ${createdEmotions.length} emotions`);

    // Create sample notifications
    const notifications = [
      {
        recipient: alice._id,
        sender: demo._id,
        type: 'friend_request',
        title: 'New Friend Request',
        message: 'sent you a friend request',
        priority: 'medium',
        category: 'social'
      },
      {
        recipient: bob._id,
        sender: alice._id,
        type: 'message',
        title: 'New Message',
        message: 'sent you a message',
        priority: 'high',
        category: 'message',
        data: { chatId: createdChats[0]._id }
      }
    ];

    const createdNotifications = await Notification.insertMany(notifications);
    console.log(`Created ${createdNotifications.length} notifications`);

    console.log('\n✅ Database initialization completed successfully!');
    console.log('\nSample users created:');
    console.log('- alice@example.com (password: password123)');
    console.log('- bob@example.com (password: password123)');
    console.log('- charlie@example.com (password: password123)');
    console.log('- diana@example.com (password: password123)');
    console.log('- demo@chatfun.com (password: demo123)');
    
  } catch (error) {
    console.error('Error initializing database:', error);
    process.exit(1);
  }
};

// Run initialization
const runInit = async () => {
  await connectDB();
  await initializeDB();
  process.exit(0);
};

// Run if called directly
if (require.main === module) {
  runInit();
}

module.exports = { connectDB, initializeDB };