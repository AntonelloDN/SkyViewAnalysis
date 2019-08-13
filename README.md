# SkyViewAnalysis

A plugin for Sketchup to calculate Sky Exposure and Sky View Factor.
![Oke svf](https://github.com/AntonelloDN/SkyViewAnalysis/blob/master/example/svf01.jpg)
## SVF:
Sky View Factor (SVFs) represents the ratio at a point in space between the visible sky and a hemisphere centered over the analyzed location (Oke 1981).
- If SVF of a point is 0 the entire sky is blocked from view by obstacles.
- If SVF of a point is 1 the entire sky is free from view by obstacles (ideal rural scenario)

There is a relation between Sky View Factor and Radiation.
<h4>for SVF = 0 :</h4>
<ol>
  <li>there is no short-wave reflection</li>
  <li>there is no long-wave nocturnal interference</li>
</ol>
<h4>for SVF > 0 :</h4>
<ol>
<li>incoming day-time short-wave reflection increases during the day</li>
<li>outgoing night-time long-wave radiation is reduced</li>
<li>incoming night-time long-wave radiation is increased</li>
<li>altered soil heat flux</li>
</ol>
<br>Urban Canyon H/W and SVF relation:
<table style="width:100%">
  <tr>
    <th>H/W</th>
    <th>SVF</th> 
  </tr>
  <tr>
    <td>Rural</td>
    <td>1.00</td> 
  </tr>
  <tr>
    <td>0.25</td>
    <td>0.89</td> 
  </tr>
  <tr>
    <td>0.5</td>
    <td>0.71</td> 
  </tr>
  <tr>
    <td>1</td>
    <td>0.45</td> 
  </tr>
  <tr>
    <td>2</td>
    <td>0.24</td> 
  </tr>
  <tr>
    <td>3</td>
    <td>0.16</td> 
  </tr>
  <tr>
    <td>4</td>
    <td>0.12</td> 
  </tr>
</table>

<p>reference: https://mau.hypotheses.org/271 (PAR KHARTWELL · 23/05/2017)</p>

## Features:
- Create Sky Exposure Mask
- Create Sky View Factor Mask
- Use many times the same dome for Sky Exposure calcultation

## Setup:
Install *rbz from Sketchup Extension Warehouse.
