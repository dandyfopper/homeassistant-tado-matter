// Enhanced JavaScript for Tado Infographic Dashboard

// Temperature color mapping function
function getTemperatureColor(temperature, targetTemperature) {
  const diff = Math.abs(temperature - targetTemperature);
  
  if (diff < 0.5) {
    // Perfect temperature - green gradient
    return 'radial-gradient(circle, #4CAF50, #66BB6A)';
  } else if (temperature > targetTemperature) {
    // Too warm - red gradient with intensity based on difference
    const intensity = Math.min(diff * 20, 100);
    return `radial-gradient(circle, hsl(${14 - intensity/10}, 100%, ${65 - intensity/5}%), hsl(${20 - intensity/10}, 100%, ${70 - intensity/5}%))`;
  } else {
    // Too cool - blue gradient with intensity based on difference
    const intensity = Math.min(diff * 20, 100);
    return `radial-gradient(circle, hsl(${207 + intensity/10}, 100%, ${65 - intensity/5}%), hsl(${195 + intensity/10}, 100%, ${70 - intensity/5}%))`;
  }
}

// Efficiency score color function
function getEfficiencyColor(score) {
  if (score >= 80) return 'linear-gradient(135deg, #4CAF50, #66BB6A)';
  if (score >= 60) return 'linear-gradient(135deg, #FF9800, #FFB74D)';
  if (score >= 40) return 'linear-gradient(135deg, #FF5722, #FF7043)';
  return 'linear-gradient(135deg, #F44336, #EF5350)';
}

// Animation functions
function pulseElement(element, color) {
  element.style.animation = `pulse-${color} 2s infinite`;
}

function updateTemperatureDisplay(entity, element) {
  const current = entity.attributes.current_temperature || 'N/A';
  const target = entity.attributes.temperature || 'N/A';
  const humidity = entity.attributes.current_humidity || 'N/A';
  const mode = entity.state || 'off';
  
  // Update background color based on temperature
  const bgColor = getTemperatureColor(parseFloat(current), parseFloat(target));
  element.style.background = bgColor;
  
  // Update status indicator
  const statusIndicator = element.querySelector('.status-indicator');
  if (statusIndicator) {
    statusIndicator.className = `status-indicator status-${mode}`;
  }
  
  // Apply appropriate animation
  if (mode === 'heat') {
    pulseElement(element, 'warm');
  } else if (mode === 'cool') {
    pulseElement(element, 'cool');
  } else if (Math.abs(current - target) < 0.5) {
    pulseElement(element, 'perfect');
  }
}

// Room visibility management
function updateRoomVisibility(numberOfBedrooms, includeGarage, includeLoft) {
  const bedrooms = ['bedroom1', 'bedroom2', 'bedroom3', 'bedroom4'];
  
  bedrooms.forEach((bedroom, index) => {
    const element = document.getElementById(bedroom);
    if (element) {
      element.style.opacity = index < numberOfBedrooms ? '1' : '0.3';
      element.style.pointerEvents = index < numberOfBedrooms ? 'auto' : 'none';
    }
  });
  
  const garage = document.getElementById('garage');
  if (garage) {
    garage.style.opacity = includeGarage ? '1' : '0.3';
    garage.style.pointerEvents = includeGarage ? 'auto' : 'none';
  }
  
  const loft = document.getElementById('loft');
  if (loft) {
    loft.style.opacity = includeLoft ? '1' : '0.3';
    loft.style.pointerEvents = includeLoft ? 'auto' : 'none';
  }
}

// Energy usage visualization
function createEnergyChart(containerId, data) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  // Simple bar chart implementation
  const maxValue = Math.max(...data.values);
  const chartHTML = data.labels.map((label, index) => {
    const height = (data.values[index] / maxValue) * 100;
    return `
      <div class="chart-bar" style="
        height: ${height}%;
        background: linear-gradient(to top, #FF6B35, #F7931E);
        margin: 2px;
        border-radius: 4px 4px 0 0;
        position: relative;
        flex: 1;
      ">
        <div class="chart-label" style="
          position: absolute;
          bottom: -20px;
          left: 50%;
          transform: translateX(-50%);
          font-size: 10px;
          color: #666;
        ">${label}</div>
        <div class="chart-value" style="
          position: absolute;
          top: -15px;
          left: 50%;
          transform: translateX(-50%);
          font-size: 9px;
          color: #333;
          font-weight: bold;
        ">${data.values[index]}</div>
      </div>
    `;
  }).join('');
  
  container.innerHTML = `
    <div style="
      display: flex;
      align-items: end;
      height: 150px;
      padding: 20px 10px;
      position: relative;
    ">
      ${chartHTML}
    </div>
  `;
}

// Weather icon mapping
function getWeatherIcon(condition) {
  const iconMap = {
    'sunny': '☀️',
    'clear-night': '🌙',
    'partlycloudy': '⛅',
    'cloudy': '☁️',
    'rainy': '🌧️',
    'snowy': '❄️',
    'windy': '💨',
    'fog': '🌫️',
    'lightning': '⛈️'
  };
  return iconMap[condition] || '🌤️';
}

// Comfort score calculation
function calculateComfortScore(rooms) {
  let totalScore = 0;
  let roomCount = 0;
  
  rooms.forEach(room => {
    if (room.current_temperature && room.target_temperature) {
      const diff = Math.abs(room.current_temperature - room.target_temperature);
      let roomScore = 100;
      
      if (diff > 0.5) roomScore -= diff * 20;
      if (room.humidity < 30 || room.humidity > 70) roomScore -= 10;
      if (room.mode === 'off' && diff > 2) roomScore -= 30;
      
      totalScore += Math.max(roomScore, 0);
      roomCount++;
    }
  });
  
  return roomCount > 0 ? Math.round(totalScore / roomCount) : 0;
}

// Initialize dashboard
function initializeDashboard() {
  // Add entrance animations
  const cards = document.querySelectorAll('.metric-card, .data-point, .glass-card');
  cards.forEach((card, index) => {
    card.style.animationDelay = `${index * 0.1}s`;
    card.classList.add('animated-entrance');
  });
  
  // Set up hover effects
  const interactiveElements = document.querySelectorAll('.interactive-element');
  interactiveElements.forEach(element => {
    element.addEventListener('mouseenter', function() {
      this.style.transform = 'scale(1.05)';
      this.style.filter = 'brightness(1.1)';
    });
    
    element.addEventListener('mouseleave', function() {
      this.style.transform = 'scale(1)';
      this.style.filter = 'brightness(1)';
    });
  });
}

// Update dashboard data
function updateDashboard(data) {
  // Update temperature displays
  if (data.rooms) {
    data.rooms.forEach(room => {
      const element = document.querySelector(`[data-room="${room.id}"]`);
      if (element) {
        updateTemperatureDisplay(room, element);
      }
    });
  }
  
  // Update comfort score
  if (data.rooms) {
    const comfortScore = calculateComfortScore(data.rooms);
    const scoreElement = document.querySelector('.comfort-score');
    if (scoreElement) {
      scoreElement.textContent = comfortScore;
      scoreElement.style.background = getEfficiencyColor(comfortScore);
    }
  }
  
  // Update energy chart
  if (data.energyUsage) {
    createEnergyChart('energy-chart', data.energyUsage);
  }
  
  // Update weather display
  if (data.weather) {
    const weatherIcon = document.querySelector('.weather-icon');
    if (weatherIcon) {
      weatherIcon.textContent = getWeatherIcon(data.weather.condition);
    }
  }
}

// Responsive design handling
function handleResize() {
  const width = window.innerWidth;
  const dashboardElement = document.querySelector('.infographic-container');
  
  if (width < 768) {
    dashboardElement.classList.add('mobile-layout');
  } else {
    dashboardElement.classList.remove('mobile-layout');
  }
}

// Event listeners
document.addEventListener('DOMContentLoaded', initializeDashboard);
window.addEventListener('resize', handleResize);

// Home Assistant connection (if available)
if (typeof hassConnection !== 'undefined') {
  hassConnection.subscribeEvents(function(event) {
    if (event.event_type === 'state_changed' && 
        event.data.entity_id.startsWith('climate.')) {
      // Update temperature display for changed climate entity
      updateTemperatureDisplay(event.data.new_state, 
        document.querySelector(`[data-entity="${event.data.entity_id}"]`));
    }
  });
}

// Export functions for use in Home Assistant templates
window.tadoInfographic = {
  getTemperatureColor,
  getEfficiencyColor,
  updateTemperatureDisplay,
  updateRoomVisibility,
  calculateComfortScore,
  updateDashboard
};
