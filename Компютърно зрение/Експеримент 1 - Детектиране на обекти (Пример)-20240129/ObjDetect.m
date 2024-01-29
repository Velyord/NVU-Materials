%Стъпка 1: Прочитане на изображение
%Прочита се референтното изображение, съдържащо обекта на интерес.
boxImage = imread('stapleRemover.jpg'); % Изображението се прочита
boxImage = rgb2gray(boxImage);% Пробразуване на цветно изображение 
% в черно-бяло с вградена функция
figure; % Извежда се на дисплея прозорец за фигура
imshow(boxImage); % изобразява се прочетенеото изображение във фигурата
title('Image of a Box'); % Присвоява се име на получената фигура
% На следващ етап се прочита целевото изображение в разхвърлена сцена.
sceneImage = imread('clutteredDesk.png');
sceneImage = rgb2gray(sceneImage);
figure;
imshow(sceneImage); % Изобразяване на изображението 
title('Image of a Cluttered Scene');% назначаване на заглавие на фигурата

%Стъпка 2: Откриване на точкови характеристики
%Откриване на точкови характеристики в двете изображения.
boxPoints = detectSURFFeatures(boxImage); % Създава се променлива с резултата 
% от ретекцията на характеристични точки на кутията
scenePoints = detectSURFFeatures(sceneImage); % Създава се променлива с резултата от 
% ретекцията на характеристични точки на цялоото изображение
%Визуализиране на най-силните черти на референтното изображение.
figure;
imshow(boxImage);
title('100 Strongest Point Features from Box Image');
hold on;
plot(selectStrongest(boxPoints, 100)); % Изчертаване на най-контрастните 100 точки
%Визуализиране на най-силните характеристики на целевото изображение.
figure;
imshow(sceneImage);
title('300 Strongest Point Features from Scene Image');
hold on; % оставя се като изходно изображение за лседващата стъпка
plot(selectStrongest(scenePoints, 300)); % Изчертаване на най-контрастните 300 точки върху изходното изображение

%Стъпка 3: Извличане на характеристики
%Можете да извлечете характеристиките на интересните точки и в двете изображения.
[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints); %
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

%Стъпка 4: Намиране на предполагаемо съвпадащи характеристики
boxPairs = matchFeatures(boxFeatures, sceneFeatures); % създаване на променлива със стойности на съвпадащи по стойност точки
%Изобразяване на съвпадащи характеристики
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
figure;
showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, ...
matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%Стъпка  5: Локализиране на обекта в сцената с помощта на предполагаеми съвпадения
% Функцията evaluationGeometricTransform изчислява трансформацията, свързваща съвпадащите точки,
% като същевременно елиминира извънредните стойности. 
% Тази трансформация ви позволява да локализирате обекта в сцената.

[tform, inlierBoxPoints, inlierScenePoints] = ...
estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
'affine');
%След това можете да покажете съвпадащите двойки точки 
% с премахнати извънредни стойности
figure;
showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, ...
inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
%След това може да се образува ограничаващия многоъгълник 
% на референтното изображение
boxPolygon = [1, 1;...  % горе вляво
size(boxImage, 2), 1;...  % горе вдясно
size(boxImage, 2), size(boxImage, 1);...  % долу вдясно
1, size(boxImage, 1);...  % долу вляво
1, 1];  % отново горе вляво за затваряне на полигона
%За да се посочи местоположението на обекта в сцената, може да се трансформира
% многоъгълника в координатна система на целевото изображение.
newBoxPolygon = transformPointsForward(tform, boxPolygon);
% След това може да се изобрази детектирания обект:
figure;
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');
% Локализиране на обекта в сцената 
% с помощта на предполагаеми съвпадения


% Стъпка 6: Откриване на друг обект
% Можете да откриете втори обект,
% като използвате същите стъпки като преди. 
% Започнете, като прочетете изображение, съдържащо
% втори обект на интерес - elephant.jpg
elephantImage = imread('elephant.png');
elephantImage = rgb2gray(elephantImage);% Пробразуване на цветно изображение 
% в черно-бяло с вградена функция
figure;
imshow(elephantImage);
title('Image of an Elephant');
% След това открийте и визуализирайте характерни точки.
elephantPoints = detectSURFFeatures(elephantImage);
figure;
imshow(elephantImage);
hold on;
plot(selectStrongest(elephantPoints, 100));
title('100 Strongest Feature Points from Elephant Image');
% Извличане на характеристики
[elephantFeatures, elephantPoints] = extractFeatures(elephantImage, ...
elephantPoints);
% Намиране на предполагаемо съвпадащи характеристики
elephantPairs = matchFeatures(elephantFeatures, sceneFeatures, ...
'MaxRatio', 0.9);
% Изобразяване на предполагаемо съвпадащи характеристики
matchedElephantPoints = elephantPoints(elephantPairs(:, 1), :);
matchedScenePoints = scenePoints(elephantPairs(:, 2), :);
figure;
showMatchedFeatures(elephantImage, sceneImage, matchedElephantPoints, ...
matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
%Локализиране на обекта в сцената с помощта 
% на предполагаеми съвпадения, 
% като същевременно се елиминират извънредните стойности
% Локализиране на обекта в сцената.
[tform, inlierElephantPoints, inlierScenePoints] = ...
estimateGeometricTransform(matchedElephantPoints, ...
matchedScenePoints, 'affine');
figure;
showMatchedFeatures(elephantImage, sceneImage, inlierElephantPoints, ...
inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
 
%изобразяване на двата обекта:
elephantPolygon = [1, 1;...  % top-left
size(elephantImage, 2), 1;...  % top-right
size(elephantImage, 2), size(elephantImage, 1);... % bottom-right
1, size(elephantImage, 1);...  % bottom-left
1,1];  % top-left again to close the polygon
newElephantPolygon = transformPointsForward(tform, elephantPolygon);
figure;
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
line(newElephantPolygon(:, 1), newElephantPolygon(:, 2), 'Color', 'g');
title('Detected Elephant and Box');


