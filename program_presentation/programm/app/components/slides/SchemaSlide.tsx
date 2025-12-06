'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Slide } from '../../../lib/types';

interface SchemaSlideProps {
  slide: Slide;
}

export default function SchemaSlide({ slide }: SchemaSlideProps) {
  const { title, schema } = slide.content;
  const [animationStep, setAnimationStep] = useState(0);

  // Auto-advance animation steps (9 steps: 0-8)
  useEffect(() => {
    if (schema?.type === 'architecture') {
      const interval = setInterval(() => {
        setAnimationStep((prev) => (prev + 1) % 9);
      }, 2500);
      return () => clearInterval(interval);
    }
  }, [schema?.type]);

  return (
    <div className={`relative w-full h-full flex items-center justify-center p-12 ${slide.background || 'bg-white'}`}>
      <div className="max-w-7xl w-full">
        {/* Title */}
        <motion.div
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <h1 className="text-4xl font-bold bg-gradient-to-r from-cyan-600 via-blue-600 to-indigo-600 bg-clip-text text-transparent mb-2">
            {title}
          </h1>
          {schema?.description && (
            <p className="text-base text-gray-600 mt-2">{schema.description}</p>
          )}
        </motion.div>

        {/* Horizontal Architecture Flow */}
        {schema?.type === 'architecture' && schema.nodes && (
          <div className="relative">
            {/* Main Flow */}
            <div className="flex items-start justify-between gap-6">
              
              {/* Column 1: Mobile + Web */}
              <motion.div 
                initial={{ opacity: 0, x: -50 }} 
                animate={{ opacity: 1, x: 0 }} 
                transition={{ duration: 0.6, delay: 0.2 }} 
                className="relative flex flex-col gap-4 flex-shrink-0"
              >
                {/* Mobile App */}
                <div className={`bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-xl p-5 shadow-xl w-44 text-center transition-all duration-300 ${animationStep === 0 ? 'ring-4 ring-blue-300 scale-105' : ''}`}>
                  <div className="text-4xl mb-2">📱</div>
                  <p className="text-sm font-bold leading-tight">Mobile App<br/>(Flutter)</p>
                </div>

                {/* Web App */}
                <div className={`bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-xl p-5 shadow-xl w-44 text-center transition-all duration-300 ${animationStep === 0 ? 'ring-4 ring-purple-300 scale-105' : ''}`}>
                  <div className="text-4xl mb-2">🌐</div>
                  <p className="text-sm font-bold leading-tight">Web App<br/>(Angular)</p>
                </div>

                {/* Request Popup for Mobile/Web */}
                <AnimatePresence>
                  {animationStep === 0 && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      exit={{ opacity: 0, scale: 0.8 }}
                      className="absolute -right-32 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white px-4 py-3 rounded-xl shadow-2xl text-xs font-medium w-32 text-center z-20 border border-gray-700"
                    >
                      <div className="mb-1 text-lg">📤</div>
                      <div className="font-bold">Envoi requête</div>
                      <div className="text-[10px] text-gray-400 mt-1">Données structure</div>
                      <div className="absolute left-0 top-1/2 transform -translate-x-1 -translate-y-1/2 w-0 h-0 border-t-4 border-t-transparent border-b-4 border-b-transparent border-r-4 border-r-gray-900 rotate-180" />
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>

              {/* Arrow 1: To API */}
              <div className="relative flex-1 h-1 bg-gray-300 rounded-full overflow-hidden self-center mt-20">
                {animationStep >= 0 && animationStep <= 1 && (
                  <motion.div 
                    initial={{ x: '-100%' }} 
                    animate={{ x: '100%' }} 
                    transition={{ duration: 1, ease: 'linear' }} 
                    className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-green-500" 
                  />
                )}
                <motion.div 
                  animate={{ x: animationStep >= 1 ? [0, 10, 0] : 0 }} 
                  transition={{ duration: 0.5, repeat: animationStep === 1 ? Infinity : 0 }} 
                  className="absolute right-0 top-1/2 transform -translate-y-1/2"
                >
                  <span className="text-green-500 text-xl">▶</span>
                </motion.div>
              </div>

              {/* Column 2: API REST */}
              <motion.div 
                initial={{ opacity: 0, scale: 0.5 }} 
                animate={{ opacity: 1, scale: 1 }} 
                transition={{ duration: 0.6, delay: 0.4 }} 
                className="relative flex-shrink-0 self-center"
              >
                <div className={`bg-gradient-to-br from-green-500 to-emerald-600 text-white rounded-xl p-6 shadow-xl w-48 text-center transition-all duration-300 ${animationStep === 1 ? 'ring-4 ring-green-300 scale-105' : ''}`}>
                  <div className="text-5xl mb-2">⚙️</div>
                  <p className="text-base font-bold leading-tight">API REST<br/>(Spring Boot)</p>
                </div>

                {/* Validation Popup */}
                <AnimatePresence>
                  {animationStep === 1 && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      exit={{ opacity: 0, scale: 0.8 }}
                      className="absolute -bottom-24 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-4 py-3 rounded-xl shadow-2xl text-xs font-medium w-36 text-center z-20 border border-gray-700"
                    >
                      <div className="mb-1 text-lg">✔️</div>
                      <div className="font-bold">Validation</div>
                      <div className="text-[10px] text-gray-400 mt-1">Traitement données</div>
                      <div className="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1 w-0 h-0 border-l-4 border-l-transparent border-r-4 border-r-transparent border-b-4 border-b-gray-900 rotate-180" />
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>

              {/* Arrow 2: To AI */}
              <div className="relative flex-1 h-1 bg-gray-300 rounded-full overflow-hidden self-center mt-0">
                {animationStep >= 2 && animationStep <= 3 && (
                  <motion.div 
                    initial={{ x: '-100%' }} 
                    animate={{ x: '100%' }} 
                    transition={{ duration: 1, ease: 'linear' }} 
                    className="absolute inset-0 bg-gradient-to-r from-green-500 to-orange-500" 
                  />
                )}
                <motion.div 
                  animate={{ x: animationStep >= 3 ? [0, 10, 0] : 0 }} 
                  transition={{ duration: 0.5, repeat: animationStep === 3 ? Infinity : 0 }} 
                  className="absolute right-0 top-1/2 transform -translate-y-1/2"
                >
                  <span className="text-orange-500 text-xl">▶</span>
                </motion.div>
              </div>

              {/* Column 3: IA Engine */}
              <motion.div 
                initial={{ opacity: 0, scale: 0.5 }} 
                animate={{ opacity: 1, scale: 1 }} 
                transition={{ duration: 0.6, delay: 0.6 }} 
                className="relative flex-shrink-0 self-center"
              >
                <div className={`bg-gradient-to-br from-orange-500 to-red-600 text-white rounded-xl p-6 shadow-xl w-48 text-center transition-all duration-300 ${animationStep === 3 ? 'ring-4 ring-orange-300 scale-105' : ''}`}>
                  <div className="text-5xl mb-2">🤖</div>
                  <p className="text-base font-bold leading-tight">IA Engine<br/>(PyTorch)</p>
                </div>

                {/* Prediction Popup */}
                <AnimatePresence>
                  {animationStep === 3 && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      exit={{ opacity: 0, scale: 0.8 }}
                      className="absolute -top-24 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-4 py-3 rounded-xl shadow-2xl text-xs font-medium w-36 text-center z-20 border border-gray-700"
                    >
                      <div className="mb-1 text-lg">🧠</div>
                      <div className="font-bold">Prédiction IA</div>
                      <div className="text-[10px] text-gray-400 mt-1">Deep Learning...</div>
                      <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1 w-0 h-0 border-l-4 border-l-transparent border-r-4 border-r-transparent border-t-4 border-t-gray-900" />
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>

              {/* Arrow 3: Back to API */}
              <div className="relative flex-1 h-1 bg-gray-300 rounded-full overflow-hidden self-center mt-0">
                {animationStep >= 4 && animationStep <= 5 && (
                  <motion.div 
                    initial={{ x: '-100%' }} 
                    animate={{ x: '100%' }} 
                    transition={{ duration: 1, ease: 'linear' }} 
                    className="absolute inset-0 bg-gradient-to-r from-orange-500 to-green-500" 
                  />
                )}
                <motion.div 
                  animate={{ x: animationStep >= 5 ? [0, 10, 0] : 0 }} 
                  transition={{ duration: 0.5, repeat: animationStep === 5 ? Infinity : 0 }} 
                  className="absolute right-0 top-1/2 transform -translate-y-1/2"
                >
                  <span className="text-green-500 text-xl">▶</span>
                </motion.div>
              </div>

              {/* Column 4: Spring Boot (duplicate for clarity) */}
              <motion.div 
                initial={{ opacity: 0, scale: 0.5 }} 
                animate={{ opacity: 1, scale: 1 }} 
                transition={{ duration: 0.6, delay: 0.8 }} 
                className="relative flex-shrink-0 self-center"
              >
                <div className={`bg-gradient-to-br from-teal-500 to-cyan-600 text-white rounded-xl p-6 shadow-xl w-48 text-center transition-all duration-300 ${animationStep === 5 ? 'ring-4 ring-teal-300 scale-105' : ''}`}>
                  <div className="text-5xl mb-2">🔄</div>
                  <p className="text-base font-bold leading-tight">Spring Boot<br/>(Processing)</p>
                </div>

                {/* Send Message Popup */}
                <AnimatePresence>
                  {animationStep === 5 && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      exit={{ opacity: 0, scale: 0.8 }}
                      className="absolute -bottom-24 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-4 py-3 rounded-xl shadow-2xl text-xs font-medium w-36 text-center z-20 border border-gray-700"
                    >
                      <div className="mb-1 text-lg">💬</div>
                      <div className="font-bold">Message envoyé</div>
                      <div className="text-[10px] text-gray-400 mt-1">→ PostgreSQL</div>
                      <div className="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1 w-0 h-0 border-l-4 border-l-transparent border-r-4 border-r-transparent border-b-4 border-b-gray-900 rotate-180" />
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>

              {/* Arrow 4: To Database */}
              <div className="relative flex-1 h-1 bg-gray-300 rounded-full overflow-hidden self-center mt-0">
                {animationStep >= 6 && animationStep <= 7 && (
                  <motion.div 
                    initial={{ x: '-100%' }} 
                    animate={{ x: '100%' }} 
                    transition={{ duration: 1, ease: 'linear' }} 
                    className="absolute inset-0 bg-gradient-to-r from-teal-500 to-indigo-500" 
                  />
                )}
                <motion.div 
                  animate={{ x: animationStep >= 7 ? [0, 10, 0] : 0 }} 
                  transition={{ duration: 0.5, repeat: animationStep === 7 ? Infinity : 0 }} 
                  className="absolute right-0 top-1/2 transform -translate-y-1/2"
                >
                  <span className="text-indigo-500 text-xl">▶</span>
                </motion.div>
              </div>

              {/* Column 5: PostgreSQL */}
              <motion.div 
                initial={{ opacity: 0, scale: 0.5 }} 
                animate={{ opacity: 1, scale: 1 }} 
                transition={{ duration: 0.6, delay: 1.0 }} 
                className="relative flex-shrink-0 self-center"
              >
                <div className={`bg-gradient-to-br from-indigo-600 to-blue-700 text-white rounded-xl p-6 shadow-xl w-44 text-center transition-all duration-300 ${animationStep === 7 ? 'ring-4 ring-indigo-300 scale-105' : ''}`}>
                  <div className="text-5xl mb-2">💾</div>
                  <p className="text-base font-bold leading-tight">PostgreSQL<br/>(Database)</p>
                </div>

                {/* Save Popup */}
                <AnimatePresence>
                  {animationStep === 7 && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      exit={{ opacity: 0, scale: 0.8 }}
                      className="absolute -top-24 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-4 py-3 rounded-xl shadow-2xl text-xs font-medium w-36 text-center z-20 border border-gray-700"
                    >
                      <div className="mb-1 text-lg">💾</div>
                      <div className="font-bold">Sauvegarde</div>
                      <div className="text-[10px] text-gray-400 mt-1">Résultat enregistré</div>
                      <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1 w-0 h-0 border-l-4 border-l-transparent border-r-4 border-r-transparent border-t-4 border-t-gray-900" />
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            </div>

            {/* Return Flow - Result to Mobile & Web */}
            <AnimatePresence>
              {animationStep === 8 && (
                <motion.div 
                  initial={{ opacity: 0 }} 
                  animate={{ opacity: 1 }} 
                  exit={{ opacity: 0 }}
                  className="mt-16"
                >
                  {/* Return Arrow Animation */}
                  <div className="relative">
                    <motion.div 
                      initial={{ scaleX: 0 }} 
                      animate={{ scaleX: 1 }} 
                      transition={{ duration: 1.5, ease: "easeInOut" }} 
                      className="h-1.5 bg-gradient-to-l from-indigo-500 via-teal-500 via-green-500 to-purple-500 rounded-full origin-right shadow-lg" 
                    />
                    <motion.div 
                      initial={{ x: '100%', opacity: 0 }} 
                      animate={{ x: '0%', opacity: 1 }} 
                      transition={{ duration: 1.5, ease: "easeInOut" }} 
                      className="absolute left-0 top-1/2 transform -translate-y-1/2"
                    >
                      <span className="text-3xl drop-shadow-lg">◀</span>
                    </motion.div>
                    
                    {/* Flowing particles on the arrow */}
                    {[...Array(6)].map((_, i) => (
                      <motion.div 
                        key={i}
                        initial={{ x: '100%', opacity: 0 }} 
                        animate={{ x: '0%', opacity: [0, 1, 0] }} 
                        transition={{ 
                          duration: 1.5, 
                          delay: i * 0.2,
                          ease: "easeInOut" 
                        }} 
                        className="absolute top-1/2 right-0 transform -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow-lg"
                      />
                    ))}
                  </div>

                  {/* Result Popups at Mobile and Web positions */}
                  <div className="relative mt-8 flex justify-between items-center px-4">
                    {/* Mobile Result Popup */}
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.5, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      transition={{ delay: 1.2, type: 'spring', stiffness: 200 }}
                      className="bg-gray-900 text-white px-6 py-4 rounded-xl shadow-2xl border border-gray-700 max-w-xs"
                    >
                      <div className="flex items-center gap-3">
                        <motion.div 
                          animate={{ scale: [1, 1.2, 1] }}
                          transition={{ duration: 0.8, repeat: Infinity }}
                          className="text-3xl"
                        >
                          📱
                        </motion.div>
                        <div>
                          <div className="font-bold text-sm mb-1">Mobile App</div>
                          <div className="text-xs text-green-400 font-medium">✅ Résultat reçu</div>
                          <div className="text-[10px] text-gray-400 mt-1">Stabilité: 96.5%</div>
                        </div>
                      </div>
                      {/* Success indicator */}
                      <motion.div 
                        initial={{ scaleX: 0 }}
                        animate={{ scaleX: 1 }}
                        transition={{ delay: 1.5, duration: 0.5 }}
                        className="mt-2 h-1 bg-gradient-to-r from-green-400 to-blue-500 rounded-full origin-left"
                      />
                    </motion.div>

                    {/* Web Result Popup */}
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.5, y: 20 }} 
                      animate={{ opacity: 1, scale: 1, y: 0 }} 
                      transition={{ delay: 1.4, type: 'spring', stiffness: 200 }}
                      className="bg-gray-900 text-white px-6 py-4 rounded-xl shadow-2xl border border-gray-700 max-w-xs"
                    >
                      <div className="flex items-center gap-3">
                        <motion.div 
                          animate={{ scale: [1, 1.2, 1] }}
                          transition={{ duration: 0.8, repeat: Infinity, delay: 0.2 }}
                          className="text-3xl"
                        >
                          🌐
                        </motion.div>
                        <div>
                          <div className="font-bold text-sm mb-1">Web App</div>
                          <div className="text-xs text-green-400 font-medium">✅ Résultat reçu</div>
                          <div className="text-[10px] text-gray-400 mt-1">Stabilité: 96.5%</div>
                        </div>
                      </div>
                      {/* Success indicator */}
                      <motion.div 
                        initial={{ scaleX: 0 }}
                        animate={{ scaleX: 1 }}
                        transition={{ delay: 1.7, duration: 0.5 }}
                        className="mt-2 h-1 bg-gradient-to-r from-green-400 to-purple-500 rounded-full origin-left"
                      />
                    </motion.div>
                  </div>

                  {/* Small success particles */}
                  {[...Array(8)].map((_, i) => (
                    <motion.div 
                      key={i}
                      initial={{ opacity: 0, scale: 0 }} 
                      animate={{ 
                        opacity: [0, 1, 0], 
                        scale: [0, 1, 0], 
                        x: Math.cos(i * 45 * Math.PI / 180) * 120 + (i % 2 === 0 ? 100 : window.innerWidth - 200), 
                        y: Math.sin(i * 45 * Math.PI / 180) * 60 + 100
                      }} 
                      transition={{ 
                        duration: 2, 
                        delay: 1.5 + i * 0.1, 
                        repeat: Infinity, 
                        repeatDelay: 2 
                      }} 
                      className="absolute w-2 h-2 bg-green-400 rounded-full"
                    />
                  ))}
                </motion.div>
              )}
            </AnimatePresence>

            {/* Progress Indicator */}
            <motion.div 
              initial={{ opacity: 0 }} 
              animate={{ opacity: 1 }} 
              transition={{ delay: 1.2 }} 
              className="absolute -bottom-24 left-1/2 transform -translate-x-1/2 bg-white/90 backdrop-blur-sm px-6 py-3 rounded-full shadow-lg border border-gray-200"
            >
              <div className="flex items-center gap-2">
                {[...Array(9)].map((_, i) => (
                  <div 
                    key={i} 
                    className={`w-2 h-2 rounded-full transition-all duration-300 ${
                      i === animationStep 
                        ? 'bg-blue-600 scale-150 shadow-lg' 
                        : i < animationStep 
                        ? 'bg-green-400' 
                        : 'bg-gray-300'
                    }`} 
                  />
                ))}
              </div>
            </motion.div>
          </div>
        )}

        {/* Tree Schema */}
        {schema?.type === 'tree' && schema.tree && (
          <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6, delay: 0.3 }} className="mt-12">
            <div className="bg-gradient-to-br from-white to-green-50 rounded-3xl p-12 shadow-2xl border-2 border-green-200">
              <pre className="text-xl font-mono text-gray-800 leading-relaxed">{schema.tree}</pre>
            </div>
            {schema.description && (
              <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.8 }} className="text-center text-gray-600 mt-6 text-lg">{schema.description}</motion.p>
            )}
          </motion.div>
        )}

        {/* Detailed Tree with Animations */}
        {schema?.type === 'detailed-tree' && schema.services && (
          <div className="mt-8">
            {/* Description */}
            {schema.description && (
              <motion.p 
                initial={{ opacity: 0 }} 
                animate={{ opacity: 1 }} 
                transition={{ delay: 0.3 }}
                className="text-center text-gray-600 mb-10 text-base"
              >
                {schema.description}
              </motion.p>
            )}

            {/* Services Grid */}
            <div className="grid grid-cols-5 gap-6">
              {schema.services.map((service, serviceIndex) => (
                <motion.div
                  key={service.name}
                  initial={{ opacity: 0, y: 50, rotateX: -15 }}
                  animate={{ opacity: 1, y: 0, rotateX: 0 }}
                  transition={{
                    duration: 0.6,
                    delay: serviceIndex * 0.15,
                    type: 'spring',
                    stiffness: 100,
                  }}
                  className="relative"
                >
                  {/* Service Card */}
                  <div className="bg-white rounded-2xl shadow-xl border-2 border-gray-100 overflow-hidden hover:shadow-2xl transition-shadow duration-300">
                    {/* Header with Icon */}
                    <motion.div
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: serviceIndex * 0.15 + 0.3 }}
                      className={`bg-gradient-to-br ${service.color} p-4 text-center`}
                    >
                      <motion.div
                        animate={{ 
                          scale: [1, 1.1, 1],
                          rotate: [0, 5, -5, 0]
                        }}
                        transition={{
                          duration: 2,
                          repeat: Infinity,
                          delay: serviceIndex * 0.2,
                        }}
                        className="text-5xl mb-2 filter drop-shadow-lg"
                      >
                        {service.icon}
                      </motion.div>
                      <h3 className="text-white font-bold text-sm uppercase tracking-wide">
                        {service.name}
                      </h3>
                      <p className="text-white/90 text-xs mt-1 font-medium">
                        {service.tech}
                      </p>
                    </motion.div>

                    {/* Folder Structure */}
                    <div className="p-5 bg-gradient-to-b from-gray-50 to-white">
                      <div className="font-mono text-xs leading-relaxed">
                        {service.structure.map((line, lineIndex) => {
                          const isFolder = line.includes('/');
                          const isRoot = !line.includes('├') && !line.includes('└');
                          const indent = line.search(/[^\s├└│]/);
                          
                          return (
                            <motion.div
                              key={lineIndex}
                              initial={{ opacity: 0, x: -20 }}
                              animate={{ opacity: 1, x: 0 }}
                              transition={{
                                delay: serviceIndex * 0.15 + 0.4 + lineIndex * 0.08,
                                duration: 0.3,
                              }}
                              className={`flex items-center gap-1 ${
                                isRoot 
                                  ? 'text-gray-900 font-bold' 
                                  : 'text-gray-700'
                              }`}
                            >
                              {/* Icon for folder/file */}
                              <motion.span
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                transition={{
                                  delay: serviceIndex * 0.15 + 0.5 + lineIndex * 0.08,
                                  type: 'spring',
                                  stiffness: 200,
                                }}
                                className="flex-shrink-0"
                              >
                                {isFolder ? '📁' : '📄'}
                              </motion.span>
                              
                              {/* Line text */}
                              <span className="whitespace-pre">
                                {line.replace('📁', '').replace('📄', '')}
                              </span>
                            </motion.div>
                          );
                        })}
                      </div>
                    </div>
                  </div>

                  {/* Connecting Lines Animation */}
                  {schema.services && serviceIndex < schema.services.length - 1 && (
                    <motion.div
                      initial={{ scaleX: 0 }}
                      animate={{ scaleX: 1 }}
                      transition={{
                        delay: serviceIndex * 0.15 + 0.8,
                        duration: 0.5,
                      }}
                      className="absolute top-1/2 -right-6 w-6 h-0.5 bg-gradient-to-r from-gray-300 to-transparent origin-left"
                    />
                  )}
                </motion.div>
              ))}
            </div>

            {/* Bottom Legend */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.2 }}
              className="mt-10 flex items-center justify-center gap-6 text-sm text-gray-600"
            >
              <div className="flex items-center gap-2">
                <span>📁</span>
                <span>Dossier</span>
              </div>
              <div className="flex items-center gap-2">
                <span>📄</span>
                <span>Fichier</span>
              </div>
              <div className="flex items-center gap-2">
                <motion.div
                  animate={{ scale: [1, 1.2, 1] }}
                  transition={{ duration: 2, repeat: Infinity }}
                  className="w-3 h-3 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"
                />
                <span>Architecture modulaire</span>
              </div>
            </motion.div>
          </div>
        )}
      </div>
    </div>
  );
}
