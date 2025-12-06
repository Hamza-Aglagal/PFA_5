'use client';

import { useState, useEffect, useMemo } from 'react';
import { motion } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface ThanksSlideProps {
  slide: Slide;
}

export default function ThanksSlide({ slide }: ThanksSlideProps) {
  const { title, subtitle, message, contact, email } = slide.content;
  const [isMounted, setIsMounted] = useState(false);

  // Fix hydration: only render animations after mount
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Stable particle positions
  const particles = useMemo(() => {
    return Array.from({ length: 20 }, (_, i) => ({
      id: i,
      initialX: (i * 50) % 100,
      initialY: (i * 40) % 80,
      delay: i * 0.1,
    }));
  }, []);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { scale: 0, opacity: 0 },
    visible: {
      scale: 1,
      opacity: 1,
      transition: {
        type: 'spring',
        stiffness: 200,
        damping: 15,
      },
    },
  };

  return (
    <div className="relative w-full h-full flex items-center justify-center overflow-hidden">
      {/* Animated Background */}
      {isMounted && (
        <div className="absolute inset-0">
          {particles.map((particle) => (
            <motion.div
              key={particle.id}
              initial={{
                x: `${particle.initialX}%`,
                y: `${particle.initialY}%`,
                scale: 0,
                opacity: 0,
              }}
              animate={{
                scale: [0, 1, 0],
                opacity: [0, 0.6, 0],
                x: [`${particle.initialX}%`, `${(particle.initialX + 20) % 100}%`, `${particle.initialX}%`],
                y: [`${particle.initialY}%`, `${(particle.initialY + 30) % 100}%`, `${particle.initialY}%`],
              }}
              transition={{
                duration: 5,
                repeat: Infinity,
                delay: particle.delay,
                ease: 'easeInOut',
              }}
              className="absolute w-4 h-4 bg-gradient-to-r from-blue-400 to-purple-400 rounded-full pointer-events-none"
            />
          ))}
        </div>
      )}

      {/* Content */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="relative z-10 text-center max-w-5xl px-12"
      >
        {/* Main Thank You */}
        <motion.div variants={itemVariants} className="mb-12">
          <motion.h1
            className="text-7xl md:text-8xl font-bold mb-8 drop-shadow-2xl
                     bg-gradient-to-r from-pink-600 via-purple-600 to-blue-600 
                     bg-clip-text text-transparent"
            animate={{
              scale: [1, 1.05, 1],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          >
            {title}
          </motion.h1>
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ delay: 0.8, duration: 1 }}
            className="h-2 w-64 mx-auto bg-gradient-to-r from-pink-400 via-purple-400 to-blue-400 rounded-full"
          />
        </motion.div>

        {/* Subtitle */}
        {subtitle && (
          <motion.div variants={itemVariants} className="mb-8">
            <p className="text-3xl text-gray-700 font-semibold">{subtitle}</p>
          </motion.div>
        )}

        {/* Message & Contact */}
        <motion.div variants={itemVariants} className="space-y-6 mb-12">
          {message && (
            <div className="bg-white/90 backdrop-blur-lg px-8 py-6 rounded-2xl 
                          border-2 border-gray-200 shadow-xl">
              <p className="text-gray-800 text-2xl font-medium">{message}</p>
            </div>
          )}
          {contact && (
            <div className="bg-white/90 backdrop-blur-lg px-8 py-6 rounded-2xl 
                          border-2 border-gray-200 shadow-xl">
              <p className="text-gray-800 text-xl">{contact}</p>
            </div>
          )}
        </motion.div>

        {/* Email/Questions */}
        {email && (
          <motion.div variants={itemVariants} className="mb-12">
            <div className="inline-flex items-center gap-4 bg-gradient-to-r from-blue-500 to-purple-600 
                          backdrop-blur-lg px-10 py-5 rounded-full border-2 border-white shadow-2xl">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <span className="text-white text-2xl font-semibold">{email}</span>
            </div>
          </motion.div>
        )}

        {/* Tech Icons */}
        <motion.div
          variants={containerVariants}
          className="flex justify-center gap-6 flex-wrap"
        >
          {[
            { emoji: '📱', label: 'Flutter', color: 'from-blue-400 to-cyan-400' },
            { emoji: '🌐', label: 'Angular', color: 'from-red-400 to-pink-400' },
            { emoji: '⚙️', label: 'Spring', color: 'from-green-400 to-emerald-400' },
            { emoji: '🐍', label: 'Python', color: 'from-yellow-400 to-orange-400' },
            { emoji: '🗄️', label: 'PostgreSQL', color: 'from-indigo-400 to-purple-400' },
          ].map((tech, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{
                scale: 1.2,
                rotate: [0, -10, 10, -10, 0],
              }}
              className={`flex flex-col items-center gap-2 bg-gradient-to-br ${tech.color} 
                        p-6 rounded-2xl shadow-xl cursor-pointer`}
            >
              <span className="text-4xl">{tech.emoji}</span>
              <span className="text-white text-sm font-bold">{tech.label}</span>
            </motion.div>
          ))}
        </motion.div>

        {/* Floating Emojis */}
        {isMounted && (
          <div className="absolute inset-0 pointer-events-none">
            {['🎓', '💡', '🚀', '✨', '🎯', '⭐'].map((emoji, index) => (
              <motion.div
                key={index}
                initial={{
                  x: `${(index * 20) % 100}%`,
                  y: '100%',
                  opacity: 0,
                }}
                animate={{
                  y: [null, -100 + '%'],
                  opacity: [0, 1, 0],
                }}
                transition={{
                  duration: 5,
                  repeat: Infinity,
                  delay: index * 0.5,
                  ease: 'easeOut',
                }}
                className="absolute text-5xl"
              >
                {emoji}
              </motion.div>
            ))}
          </div>
        )}
      </motion.div>
    </div>
  );
}
