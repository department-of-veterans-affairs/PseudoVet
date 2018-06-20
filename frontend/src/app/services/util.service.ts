export class UtilService {
  static GENDER_CONDITIONS = {
    'female': `gender == 'Female'`,
    'male': `gender == 'Male'`
  };

  /**
   * according backend rule get the gender
   * @param rule the backend rule string
   * @return {string} the gender
   */
  static getGenderFromExclusions (rule) {
    if (rule) {
      if (rule.indexOf(UtilService.GENDER_CONDITIONS['none']) >= 0) {
        return 'None';
      } else if (rule.indexOf(UtilService.GENDER_CONDITIONS['female']) >= 0) {
        return 'Female';
      } else if (rule.indexOf(UtilService.GENDER_CONDITIONS['male']) >= 0) {
        return 'Male';
      }
    }
    return 'None';
  }

  /**
   * get age from backend exclusion
   * @param rule the backend rule
   * @return {string} the age value
   */
  static getAgeFromExclusions (rule) {
    if (rule) {
      const index = rule.indexOf('total_age');
      if (index < 0) {
        return '';
      }
      return rule.substr(index + 'total_age <= '.length, rule.length);
    }
    return '';
  }

  /**
   * get exclusions by frontend condition item
   * @param item the condition item
   */
  static getExclusionsByItem (item) {
    let exclude = UtilService.GENDER_CONDITIONS[item.gender.toLowerCase()];
    if (!item.age || item.age.length === 0 || item.age <= 0) {
      return exclude;
    }
    if (item.gender === 'None') {
      exclude = `total_age <= ${item.age}`;
    } else {
      exclude = exclude + ` and total_age <= ${item.age}`;
    }
    return exclude;
  }

  /**
   * get configuration description
   * @param configObj the backend config object
   * @return {string} the description
   */
  static getDescriptionByBackendConfig (configObj) {
    return `${configObj.studyProfile.studyProfile} / ${configObj.numberOfPatients} patients / ${
      configObj.maleRatio}:${configObj.femaleRatio} male-female ratio`;
  }
}
