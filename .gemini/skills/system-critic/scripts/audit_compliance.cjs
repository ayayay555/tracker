const fs = require('fs');
const path = require('path');

const MANDATORY_PHYSICS = 'BouncingScrollPhysics';
const MANDATORY_CURRENCY = '₱';
const PROHIBITED_PKGS = ['firebase', 'sqflite', 'riverpod', 'flutter_bloc', 'provider'];

function auditFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const results = [];

  // Check for Physics in list views
  if (content.includes('ListView') || content.includes('SingleChildScrollView')) {
    if (!content.includes(MANDATORY_PHYSICS)) {
      results.push(`🚨 CRITIQUE: ${filePath} uses a scroll view but is missing ${MANDATORY_PHYSICS}. Standard physics for this project is "BouncingScrollPhysics".`);
    }
  }

  // Check for Currency (basic check)
  if (content.includes('Text(') && (content.includes('$') || content.includes('USD'))) {
    results.push(`🚨 CRITIQUE: ${filePath} appears to use non-PHP currency markers. All currency must be "₱".`);
  }

  // Check for Prohibited Packages in imports
  PROHIBITED_PKGS.forEach(pkg => {
    if (content.includes(`import 'package:${pkg}`)) {
      results.push(`❌ VIOLATION: ${filePath} imports "${pkg}". This project strictly uses "StatefulWidget" and "TransactionManager" only.`);
    }
  });

  return results;
}

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

const libPath = path.join(process.cwd(), 'lib');
let allCritiques = [];

if (fs.existsSync(libPath)) {
  walkDir(libPath, (filePath) => {
    if (filePath.endsWith('.dart')) {
      const fileResults = auditFile(filePath);
      allCritiques = allCritiques.concat(fileResults);
    }
  });
}

if (allCritiques.length === 0) {
  console.log('✅ SYSTEM AUDIT: System is operating within defined architectural standards.');
} else {
  console.log('--- SYSTEM CRITIQUE REPORT ---');
  allCritiques.forEach(c => console.log(c));
}
