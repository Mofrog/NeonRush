extends Node
class_name GameMath


static func calc_acc(data):
	var all_results = data["Perfect"] + data["Good"] + data["Bad"] + data["Miss"]
	if all_results == 0: return 0.0
	return 100.0 * (data["Perfect"] + 0.8 * data["Good"] + 0.6 * data["Bad"]) / all_results


static func calc_time_mult(time, perfect_time): 
	if time == 0: return 0.01
	var a = float(perfect_time) / float(time)
	if a < 0.6: return 0.26
	elif a > 1.25: return 2.5
	else: return (a - 1) * pow(2.5, a) + 1


static func calc_jumps_mult(jumps, perfect_jumps): 
	if jumps == 0: return 0.01
	var a = float(perfect_jumps) / float(jumps)
	if a < 0.6: return 0.26
	elif a > 1.25: return 2.5
	else: return pow(a * 2, 2.0) * log(a) + 1


static func calc_acc_mult(acc): 
	return 2.0 / (4.0 * ((100.0 - float(acc)) / 100.0) + 2.0)


static func calc_score(score, t_m, j_m, a_m): return (t_m * j_m / 2.0) * a_m * score * 2.0


static func get_score_mult(t_m, j_m, a_m): return (t_m * j_m / 2.0) * a_m * 2.0


static func get_grade(s_m):
	var grade = {
		"Grade" : "D",
		"Info" : "Try harder next time//"
	}
	if s_m >= 1.1:
		grade["Grade"] = "SS"
		grade["Info"] = "Perfection is a life goal!"
	elif s_m >= 1.0:
		grade["Grade"] = "S"
		grade["Info"] = "Almost perfect!"
	elif s_m >= 0.85:
		grade["Grade"] = "A"
		grade["Info"] = "You can see the top!"
	elif s_m >= 0.7:
		grade["Grade"] = "B"
		grade["Info"] = "Just good."
	elif s_m >= 0.55: 
		grade["Grade"] = "C"
		grade["Info"] = "It's not impressive..."
	return grade
